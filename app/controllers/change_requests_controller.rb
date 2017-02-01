class ChangeRequestsController < ApplicationController
  before_action :set_change_request, only: [:show, :edit, :update, :destroy, :approve, :reject, :edit_grace_period_notes, :edit_implementation_notes, :print]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]
  before_action :not_closed_required, only: [:destroy]
  before_action :submitted_required, only: [:edit]
  before_action :reference_rollbacked_required, only: [:create_hotfix]
  require 'notifier.rb'
  require 'slack_notif.rb'

  def index
    if params[:search]
      search = ChangeRequest.solr_search do
        fulltext params[:search]
        order_by :created_at, :desc
      end
      @change_requests = search.results
    elsif params[:type]
      @q = ChangeRequest.ransack(params[:q])
      case params[:type]
      when 'approval'
        @change_requests = ChangeRequest.where(id: Approval.where(user_id: current_user.id, approve: nil).collect(&:change_request_id)).order(id: :desc)
      when 'relevant'
        @change_requests = ChangeRequest.where(id: current_user.associated_change_requests.collect(&:id)).order(id: :desc)
      end
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
        #offset = params[:page] || 1
        #@change_requests.order("created_at desc").limit(13).offset(offset)
        if params[:cr_page] == "all_page"
          cr_ids = @change_requests.ids
          email = current_user.email
          ChangeRequestJob.perform_async(cr_ids, email)
          flash[:notice] = "CSV is being sended to #{email}"
          redirect_to change_requests_path          
        else
          @change_requests = @change_requests.where.not(aasm_state: 'draft').page(params[:page] || 1).per(params[:per_page] || 10)
          render csv: @change_requests, filename: 'change_requests', force_quotes: true
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
    User.all.each do |user|
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
    @users = User.all.collect{|u| [u.name, u.id]}
    @approvers = User.approvers.collect{|u| [u.name, u.id]}
  end

  def edit
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = @change_request.tag_list
    @current_collaborators = @change_request.collaborators.collect{|u| u.id}
    @current_implementers = @change_request.implementers.collect{|u| u.id}
    @current_testers = @change_request.testers.collect{|u| u.id}
    @users = User.all.collect{|u| [u.name, u.id]}
    @approvers = User.approvers.collect{|u| [u.name, u.id]}
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
    @current_approvers = Array.wrap(params[:approvers_list])
    @current_implementers = Array.wrap(params[:implementers_list])
    @current_testers = Array.wrap(params[:testers_list])
    @current_collaborators = Array.wrap(params[:collaborators_list])
    @change_request.set_approvers(@current_approvers)
    @change_request.set_implementers(@current_implementers)
    @change_request.set_testers(@current_testers)
    @change_request.set_collaborators(@current_collaborators)
    respond_to do |format|
      if @change_request.save
        associated_user_ids = ["#{@change_request.user.id}"]
        associated_user_ids.concat(@current_approvers)
        associated_user_ids.concat(@current_implementers)
        associated_user_ids.concat(@current_testers)
        associated_user_ids.concat(@current_collaborators)
        @change_request.associated_user_ids = associated_user_ids.uniq
        @status = @change_request.change_request_statuses.new(:status => 'submitted')
        @status.save
        Notifier.cr_notify(current_user, @change_request, 'new_cr')
        SlackNotif.new.notify_new_cr @change_request
        Thread.new do
          UserMailer.notif_email(@change_request.user, @change_request, @status).deliver
          ActiveRecord::Base.connection.close
        end
        flash[:create_cr_notice] = 'Change request was successfully created.'
        format.html { redirect_to @change_request }
        format.json { render :show, status: :created, location: @change_request }
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = []
        @users = User.all.collect{|u| [u.name, u.id]}
        @approvers = User.approvers.collect{|u| [u.name, u.id]}
        format.html { render :new }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:search].blank?
      redirect_to change_requests_path
    end
    @search = ChangeRequest.solr_search do
      fulltext params[:search], highlight: true
      order_by(:created_at, :desc)
      paginate page: params[:page] || 1, per_page: 10
    end
  end

  def update
    @current_approvers = Array.wrap(params[:approvers_list])
    @current_implementers = Array.wrap(params[:implementers_list])
    @current_testers = Array.wrap(params[:testers_list])
    @current_collaborators = Array.wrap(params[:collaborators_list])
    @change_request.update_approvers(@current_approvers)
    @change_request.set_implementers(@current_implementers)
    @change_request.set_testers(@current_testers)
    @change_request.set_collaborators(@current_collaborators)
    respond_to do |format|
      if @change_request.update(change_request_params)
        associated_user_ids = ["#{@change_request.user.id}"]
        associated_user_ids.concat(@current_approvers)
        associated_user_ids.concat(@current_implementers)
        associated_user_ids.concat(@current_testers)
        associated_user_ids.concat(@current_collaborators)
        @change_request.associated_user_ids = associated_user_ids.uniq
        Notifier.cr_notify(current_user, @change_request, 'update_cr')
        SlackNotif.new.notify_update_cr @change_request
        flash[:update_cr_notice] = 'Change request was successfully updated.'
        format.html { redirect_to @change_request }
        format.json { render :show, status: :ok, location: @change_request }
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = @change_request.tag_list
        @users = User.all.collect{|u| [u.name, u.id]}
        @approvers = User.approvers.collect{|u| [u.name, u.id]}
        format.html { render :edit }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @change_request.destroy
    respond_to do |format|
      flash[:destroy_cr_notice] = 'Change request was successfully destroyed.'
      format.html { redirect_to change_requests_url }
      format.json { head :no_content }
    end
  end

  def deleted
    @change_requests = ChangeRequestVersion.where(event: 'destroy')
                        .page(params[:page]).per(params[:per_page])
  end
  def approve
    approver = Approval.where(change_request_id: @change_request.id, user_id: current_user.id).first
    accept_note = params["notes"]
    if approver.nil?
      flash[:not_eligible_notice] = 'You are not eligible to approve this Change Request'
    elsif accept_note.blank?
      flash[:reject_reason_notice] = 'You must fill accept notes'
    else
      approver.approve = true
      approver.approval_date = Time.current
      approver.notes = accept_note
      approver.save!
      Notifier.cr_notify(current_user, @change_request, 'cr_approved')
      flash[:status_changed_notice] = 'Change Request Approved'
    end
    redirect_to @change_request
    return
  end

  def reject
    approver = Approval.where(change_request_id: @change_request.id, user_id: current_user.id)
    reject_reason = params["notes"]
    if approver.empty?
      flash[:not_eligible_notice] = 'You are not eligible to reject this Change Request'
    elsif reject_reason.blank?
      flash[:reject_reason_notice] = 'You must fill reject reason'
    else
      Notifier.cr_notify(current_user, @change_request, 'cr_rejected')
      approver.update_all(:approve => false, :notes => reject_reason)
      flash[:status_changed_notice] = 'Change Request Rejected'
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
    @users = User.all.collect{|u| [u.name, u.id]}
    @current_approvers = @old_change_request.approvals.collect(&:user_id)
    @change_request = @old_change_request.dup
    @approvers = User.approvers.collect{|u| [u.name, u.id]}
    # Clear certain fields
    @change_request.user = current_user
    @change_request.schedule_change_date = nil
    @change_request.planned_completion = nil
    @change_request.grace_period_starts = nil
    @change_request.grace_period_end = nil
    render 'new'
  end

  def create_hotfix
    @change_request = ChangeRequest.new
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = []
    @current_collaborators = []
    @current_approvers = []
    @users = User.all.collect{|u| [u.name, u.id]}
    @approvers = User.approvers.collect{|u| [u.name, u.id]}
    @current_implementers = []
    @current_testers = []
    @change_request.reference_cr_id = @reference_cr.id
    render 'new'
  end

  respond_to :json
  def change_requests_by_success_rate
    #default status is weekly
    status = 'weekly'
    start_time = Time.now.beginning_of_month
    end_time = Time.now.end_of_month
    if(params[:start_time])
      start_time = params[:start_time].in_time_zone('Asia/Jakarta')
    end
    if(params[:end_time])
      end_time = params[:end_time].in_time_zone('Asia/Jakarta')
    end
    if(params[:tag])
      tag = params[:tag]
    end
    if(params[:status])
      status = params[:status]
    end

    if status == 'weekly'
      result = change_request_by_success_rate_weekly(start_time, end_time, tag)
    else
      result = change_request_by_success_rate_monthly(start_time, end_time, tag)
    end
    render :text => result.to_json
  end

  def change_request_by_success_rate_weekly(start_time, end_time, tag)
    i = 1
    result = []
    while start_time <= end_time do
      start_week = start_time
      if start_week.end_of_week > end_time
        end_week = end_time
      else
        end_week = start_week.end_of_week
      end
      if tag==nil
        success = ChangeRequest.where("status = 'success' AND closed_date <= ? AND closed_date >= ?",end_week, start_week)
        failed = ChangeRequest.where("status = 'failed' AND closed_date <= ? AND closed_date >= ?",end_week, start_week)
      else
        success = ChangeRequest.where("status = 'success' AND closed_date <= ? AND closed_date >= ?",end_week, start_week).tagged_with(tag)
        failed = ChangeRequest.where("status = 'failed' AND closed_date <= ? AND closed_date >= ?",end_week, start_week).tagged_with(tag)
      end
      total_success = success.blank? ? 0 : success.count
      total_failed = failed.blank? ? 0 : failed.count
      result << {
        success: total_success,
        failed: total_failed,
        label: start_week.strftime("%d/%m")+' - '+end_week.strftime("%d/%m")
      }
      start_time = (end_week + 1.day).beginning_of_day
      i = i + 1
    end
    final_result = [{title: 'Weekly'}, result]
    final_result
  end

  def change_request_by_success_rate_monthly(start_time, end_time, tag)
    result = []
    i = 1
    while start_time <= end_time do
      start_month = start_time
      if start_month.end_of_month > end_time
        end_month = end_time
      else
        end_month = start_month.end_of_month
      end
      if tag==nil
        success = ChangeRequest.where("status = 'success' AND closed_date <= ? AND closed_date >= ?",end_month, start_month)
        failed = ChangeRequest.where("status = 'failed' AND closed_date <= ? AND closed_date >= ?",end_month, start_month)
      else
        success = ChangeRequest.where("status = 'success' AND closed_date <= ? AND closed_date >= ?",end_month, start_month).tagged_with(tag)
        failed = ChangeRequest.where("status = 'failed' AND closed_date <= ? AND closed_date >= ?",end_month, start_month).tagged_with(tag)
      end
      total_success = success.blank? ? 0 : success.count
      total_failed = failed.blank? ? 0 : failed.count
      result << {
        success: total_success,
        failed: total_failed,
        label: start_month.strftime("%B")
      }
      start_time = (end_month + 1.day).beginning_of_day
      i = i + 1
    end
    final_result = [{title: 'Monthly'}, result]
    final_result
  end

  private

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
            :schedule_change_date, :planned_completion, :grace_period_starts,
            :grace_period_end, :implementation_notes, :grace_period_notes,
            :requestor_name, :definition_of_success, :definition_of_failed,
            :category_application, :category_network_equipment,:category_server, :category_user_access,
            :category_other,:other_dependency,:solving_duration,
            :type_security_update,:type_install_uninstall,
            :type_configuration_change, :type_emergency_change, :type_other,
            implementers_attributes: [:id, :name, :position, :_destroy],
            testers_attributes: [:id, :name, :position, :_destroy],
            :tag_list => [], :collaborators_list => [])
    end

    def owner_required
      redirect_to change_requests_url unless
      current_user == @change_request.user || current_user.is_admin || (current_user.role == 'release_manager') || current_user.collaborate_change_requests.include?(@change_request)
    end
    def submitted_required
      if @change_request.closed?
        redirect_to change_requests_path
      elsif @change_request.scheduled? || @change_request.deployed?
        redirect_to implementation_notes_path
      else
        redirect_to graceperiod_path if !@change_request.submitted?
      end
    end
    def not_closed_required
      redirect_to change_requests_path unless !@change_request.closed?
    end
    def reference_rollbacked_required
      @reference_cr = ChangeRequest.find(params[:id])
      redirect_to change_requests_path unless @reference_cr.rollbacked?
    end

end
