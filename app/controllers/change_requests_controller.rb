class ChangeRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_change_request, only: [:show, :edit, :update, :destroy, :approve, :reject, :edit_grace_period_notes, :edit_implementation_notes, :print]
  before_action :owner_required, only: [:edit, :update, :destroy]
  before_action :not_closed_required, only: [:destroy]
  before_action :submitted_required, only: [:edit]
  before_action :reference_required, only: [:create_hotfix]
  before_action :role_not_approver_required, only: :edit
  require 'notifier.rb'
  require 'slack_notif.rb'
  require 'calendar_service.rb'

  def index
    if params[:type]
      @q = ChangeRequest.ransack(params[:q])
      case params[:type]
      when 'approval'
        @change_requests = ChangeRequest.where(id: Approval.where(user_id: current_user.id, approve: nil).collect(&:change_request_id))
      when 'relevant'
        @change_requests = current_user.associated_change_requests
      end
      @change_requests = @change_requests.where.not(aasm_state: 'draft').order(id: :desc)
    else
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).order(id: :desc)
      @change_requests = @change_requests.tagged_with(params[:tag_list]) if params[:tag_list]
    end
    respond_to do |format|
      format.html do
        @change_requests = @change_requests.page(params[:page]).per(params[:per_page])
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
      end
      format.csv do
        if params[:page].present?
          @change_requests = @change_requests.page(params[:page] || 1).per(params[:per_page] || 20)
          render csv: @change_requests, filename: 'change_requests', force_quotes: true
        else
          enumerator = Enumerator.new do |lines|
            lines << ChangeRequest.to_comma_headers.to_csv
            ChangeRequest.order('id DESC').each do |record|
              lines << record.to_comma.to_csv
            end
          end
          self.stream('change_requests_all.csv', 'text/csv', enumerator)
        end
      end
    end
  end

  def show
    @version = @change_request.versions
    @change_request_status = ChangeRequestStatus.new
    @change_request.mark_as_read! :for => current_user
    Notifier.cr_read(current_user,@change_request)
    approve = Approval.where(change_request_id: @change_request.id).where(user_id: current_user.id).first
    @eligible_to_approve = true
    if(approve == nil)
      #approver for change request with current user id not present, so the user not eligible
      @eligible_to_approve = false
    else
      #the status of cr approval, it can be : true, false or nil (nil is not decided yet by approver)
      @approved = approve.approve
    end
    @hotfixes = ChangeRequest.where(reference_cr_id: @change_request.id)
    #Notifier.mark_as_read(notifica)
    @usernames = []
    User.active.each do |user|
      @usernames <<  user.email.split("@").first
    end
    @cr_statuses = @change_request.change_request_statuses
  end

  def new
    @change_request = ChangeRequest.new
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = []
    @current_collaborators = []
    @current_approvers = []
    @current_implementers = []
    @current_testers = []
    @users = User.active.collect{|u| [u.name, u.id] }
    @approvers = User.approvers.active.collect{|u| [u.name, u.id] if u.id != current_user.id }
  end

  def edit
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = @change_request.tag_list
    @current_collaborators = @change_request.collaborators.collect{|u| u.id}
    @current_implementers = @change_request.implementers.collect{|u| u.id}
    @current_testers = @change_request.testers.collect{|u| u.id}
    @users = User.active.collect{|u| [u.name, u.id] }
    @approvers = User.approvers.active.collect{|u| [u.name, u.id] if u.id != current_user.id }
    @current_approvers = @change_request.approvals.collect(&:user_id)
  end

  def edit_grace_period_notes
  end

  def edit_implementation_notes
  end

  def print
    render layout:false
  end

  def create
    @change_request = current_user.ChangeRequests.build(change_request_params)
    @change_request.requestor_position = current_user.position
    respond_to do |format|
      unless @change_request.save
        @change_request.save(:validate=> false)
        flash[:notice] = 'Change request was created as a draft.'
        flash[:invalid] = @change_request.errors.full_messages
        @status = @change_request.change_request_statuses.new(:status => 'draft')
        @status.save
      else
        event = calendar_service.assign_event_for(@change_request)
        @change_request.submit!
        @change_request.save
        @status = @change_request.change_request_statuses.new(:status => 'submitted')
        @status.save
        Notifier.cr_notify(current_user, @change_request, 'new_cr')
        NewChangeRequestSlackNotificationJob.perform_async(@change_request)
        Thread.new do
          UserMailer.notif_email(@change_request.user, @change_request, @status).deliver_now
          ActiveRecord::Base.connection.close
        end
        flash[:success] = 'Change request was successfully created.'
        flash[:success] += " Calendar event creation failed: #{event.error_messages}." unless event.success?
      end
      format.html { redirect_to @change_request }
      format.json { render :show, status: :created, location: @change_request }
    end
  end

  def search
    if params[:search].blank?
      redirect_to change_requests_path
    end
    @search = ChangeRequest.solr_search do
      fulltext params[:search], highlight: true
      order_by(:created_at, :desc)
      paginate page: params[:page] || 1, per_page: 20
    end
  end

  def update
    respond_to do |format|
      if @change_request.update(change_request_params)
        event = calendar_service.assign_event_for(@change_request)
        if @change_request.draft?
          @change_request.submit!
          @change_request.save
          @status = @change_request.change_request_statuses.new(:status => 'submitted')
          @status.save
        end 
        Notifier.cr_notify(current_user, @change_request, 'update_cr')
        UpdateChangeRequestSlackNotificationJob.perform_async(@change_request)

        flash[:success] = 'Change request was successfully updated.'
        flash[:success] += " Calendar event creation failed: #{event.error_messages}." unless event.success?
        format.html { redirect_to @change_request }
        format.json { render :show, status: :ok, location: @change_request }
      else
        if @change_request.draft?
          @change_request.save(:validate => false)
          flash[:success] = "Change request draft id: #{@change_request.id} was successfully updated."
          format.html { redirect_to @change_request }
          format.json { render :show, status: :ok, location: @change_request }
        else
          @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
          @current_tags = @change_request.tag_list
          @users = User.active.collect{|u| [u.name, u.id]}
          @approvers = User.approvers.active.collect{|u| [u.name, u.id] if u.id != current_user.id}
          @current_approvers = Array.wrap(change_request_params[:approver_ids])
          @current_implementers = Array.wrap(change_request_params[:implementer_ids])
          @current_testers = Array.wrap(change_request_params[:tester_ids])
          @current_collaborators = Array.wrap(change_request_params[:collaborator_ids])
          format.html { render :edit }
          format.json { render json: @change_request.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @change_request.destroy
    respond_to do |format|
      flash[:success] = 'Change request was successfully destroyed.'
      format.html { redirect_to change_requests_url }
      format.json { head :no_content }
    end
  end

  def deleted
    @change_requests = ChangeRequestVersion.where(event: 'destroy')
                        .page(params[:page]).per(params[:per_page])
  end

  def approve
    approval = Approval.where(change_request_id: @change_request.id, user_id: current_user.id).first
    accept_note = params["notes"]
    if approval.nil?
      flash[:alert] = 'You are not eligible to approve this Change Request'
    elsif accept_note.blank?
      flash[:notice] = 'You must fill accept notes'
    else
      approval.approve = true
      approval.approval_date = Time.current
      approval.notes = accept_note
      approval.save!
      Notifier.cr_notify(current_user, @change_request, 'cr_approved')
      ApprovalChangeRequestSlackNotificationJob.perform_async(@change_request, approval)
      flash[:success] = 'Change Request Approved'
    end
    redirect_to @change_request
    return
  end

  def reject
    approval = Approval.where(change_request_id: @change_request.id, user_id: current_user.id).first
    reject_reason = params["notes"]
    if approval.nil?
      flash[:alert] = 'You are not eligible to reject this Change Request'
    elsif reject_reason.blank?
      flash[:notice] = 'You must fill reject reason'
    else
      Notifier.cr_notify(current_user, @change_request, 'cr_rejected')
      approval.update(:approve => false, :notes => reject_reason)
      flash[:notice] = 'Change Request Rejected'
      ApprovalChangeRequestSlackNotificationJob.perform_async(@change_request, approval)
    end
    redirect_to @change_request
  end

  def duplicate
    @old_change_request = ChangeRequest.find(params[:id])
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = @old_change_request.tag_list
    @current_collaborators = @old_change_request.collaborators.collect{|u| u.id}
    @current_implementers = @old_change_request.implementers.collect{|u| u.id}
    @current_testers = @old_change_request.testers.collect{|u| u.id}
    @users = User.active.collect{|u| [u.name, u.id] }
    @current_approvers = @old_change_request.approvals.collect(&:user_id)
    @change_request = @old_change_request.dup
    @approvers = User.approvers.active.collect{|u| [u.name, u.id] if u.id != current_user.id }
    # Clear certain fields
    @change_request.user = current_user
    @change_request.schedule_change_date = nil
    @change_request.planned_completion = nil
    @change_request.grace_period_starts = nil
    @change_request.grace_period_end = nil
    render 'new'
  end

  def create_hotfix
    @old_change_request = ChangeRequest.find(params[:id])
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = @old_change_request.tag_list
    @current_collaborators = @old_change_request.collaborators.collect{|u| u.id}
    @current_implementers = @old_change_request.implementers.collect{|u| u.id}
    @current_testers = @old_change_request.testers.collect{|u| u.id}
    @users = User.active.collect{|u| [u.name, u.id] }
    @current_approvers = @old_change_request.approvals.collect(&:user_id)
    @change_request = @old_change_request.dup
    @approvers = User.approvers.active.collect{|u| [u.name, u.id] if u.id != current_user.id }
    # Clear certain fields
    @change_request.user = current_user
    @change_request.schedule_change_date = nil
    @change_request.planned_completion = nil
    @change_request.grace_period_starts = nil
    @change_request.grace_period_end = nil

    @change_request.reference_cr_id = @reference_cr.id
    render 'new'
  end

  respond_to :json
  def change_requests_by_success_rate
    status = params[:status] ? params[:status] : 'weekly'
    start_time = params[:start_time] ? Time.parse(params[:start_time]) : Time.now.beginning_of_month
    end_time = params[:end_time] ? Time.parse(params[:end_time]) : Time.now.end_of_month
    status = params[:status] ? params[:status] : 'weekly'
    tag = params[:tag]

    if status == 'weekly'
      change_requests = ChangeRequest.group_by_week(:closed_date, range: start_time..end_time)
    else
      change_requests = ChangeRequest.group_by_month(:closed_date, format: "%b %Y", range: start_time..end_time)
    end

    if tag.nil?
      change_requests.tagged_with(tag)
    end

    succeeded = change_requests.where(aasm_state: 'succeeded').count
    failed = change_requests.where(aasm_state: 'failed').count
    rollbacked = change_requests.where(aasm_state: 'rollbacked').count

    results = succeeded.map do |k,x|
      {
        label: "#{(k - 1.week).strftime("%d/%m")} - #{k.strftime("%d/%m")}",
        succeeded: x,
        failed: failed[k],
        rollbacked: rollbacked[k]
      }
    end

    final_result = [{title: status.humanize}, results]
    render :text => final_result.to_json
  end

  private

    def calendar_service
      CalendarService.new(current_user)
    end

    def set_change_request
      if params[:change_request_id]
        @change_request = ChangeRequest.find(params[:change_request_id])
      else
        @change_request = ChangeRequest.find(params[:id])
      end
    end

    def change_request_params
      params.require(:change_request).permit(:reference_cr_id, :change_summary, :priority, :db,
            :os, :net, :category, :cr_type, :change_requirement,
            :business_justification, :note, :analysis,
            :solution, :impact, :scope, :design, :backup,
            :testing_environment_available, :testing_procedure, :testing_notes,
            :downtime_expected, :expected_downtime_in_minutes,
            :schedule_change_date, :planned_completion, :grace_period_starts,
            :grace_period_end, :implementation_notes, :grace_period_notes,
            :requestor_name, :definition_of_success, :definition_of_failed,
            :category_application, :category_network_equipment,:category_server, :category_user_access,
            :category_other,:other_dependency,:solving_duration,
            :type_security_update,:type_install_uninstall,
            :type_configuration_change, :type_emergency_change, :type_other,
            implementers_attributes: [:id, :name, :position, :_destroy],
            testers_attributes: [:id, :name, :position, :_destroy],
            :tag_list => [], :implementer_ids => [], :tester_ids => [], 
            :collaborator_ids => [], :approver_ids => []).tap do |params| 
              normalized_array_fields = [:approver_ids, :implementer_ids, :tester_ids, :collaborator_ids]
              normalized_array_fields.each do |field|
                params[field].select!{ |id| id.present? }.map!{ |id| id.to_i} if params[field].present?
              end
            end
    end

    def owner_required
      redirect_to change_requests_url unless
      current_user == @change_request.user || current_user.is_admin || (current_user.role == 'release_manager') || current_user.collaborate_change_requests.include?(@change_request)
    end

    def submitted_required
      if @change_request.draft?
        #do nothing
      elsif @change_request.terminal_state?
        redirect_to change_requests_path
      elsif @change_request.deployed?
        redirect_to implementation_notes_path
      else
        redirect_to graceperiod_path if !@change_request.submitted?
      end
    end

    def not_closed_required
      redirect_to change_requests_path unless !@change_request.closed?
    end

    def reference_required
      @reference_cr = ChangeRequest.find(params[:id])
      redirect_to change_requests_path unless @reference_cr.rollbacked? || @reference_cr.failed?
    end

    def role_not_approver_required
      if (Approval.where(change_request_id:params[:id], user_id:current_user.id).any?)
        flash[:alert] = "As an approver, you are not allowed to edit this change request"
        redirect_to change_requests_path
      end
    end
end
