class ChangeRequestsController < ApplicationController
  before_action :set_change_request, only: [:show, :edit, :update, :destroy, :approve, :reject, :edit_grace_period_notes, :edit_implementation_notes, :print]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]
  before_action :not_closed_required, only: [:destroy]
  before_action :submitted_required, only: [:edit]
  require 'notifier.rb'
  def index
    if params[:tag]
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).tagged_with(params[:tag]).order(id: :desc).page(params[:page]).per(params[:per_page])
    elsif params[:tag_list]
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).tagged_with(params[:tag_list]).order(id: :desc).page(params[:page]).per(params[:per_page])
    else
      if current_user.role == 'release_manager' || current_user.role == 'approver'
        #populate all CR if release_manager/approver
        @q = ChangeRequest.ransack(params[:q])
      else
        @q = ChangeRequest.where(user_id: current_user.id).ransack(params[:q])
      end
      @change_requests = @q.result(distinct: true).order(id: :desc).page(params[:page]).per(params[:per_page])
    end
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    #@n = Notifier.notify
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
    #Notifier.mark_as_read(notifica)
  end

  def new
    @change_request = ChangeRequest.new
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = []
    @current_collaborators = []
    @current_approvers = []

    @users = User.all.collect{|u| [u.name, u.id]}
    @approvers = User.approvers.collect{|u| [u.name, u.id]}
    @current_implementers = []
    @current_testers = []
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

    #Populating approver list
    @approvers_list = params[:approvers_list]? params[:approvers_list] : []
    @change_request.approvals = []
    @approvers_list.each do |approver|
      @tmp_user = User.find(approver)
      @approval = Approval.create(user: @tmp_user, change_request: @change_request)
      @change_request.approvals << @approval
    end

    #Populating implementers list
    @implementers_list = params[:implementers_list]? params[:implementers_list] : []
    @change_request.implementers = []
    @implementers_list.each do |implementer_id|
      @change_request.implementers << User.find(implementer_id)
    end

    #Populating testers list
    @testers_list = params[:testers_list]? params[:testers_list] : []
    @change_request.testers = []
    @testers_list.each do |tester_id|
    @change_request.testers << User.find(tester_id)
  end

    respond_to do |format|
      if @change_request.save

        @collaborators_list = params[:collaborators_list]? params[:collaborators_list] : []
        @change_request.collaborators = []
        @collaborators_list.each do |collaborator_id|
          @change_request.collaborators << User.find(collaborator_id)
        end

        @status = @change_request.change_request_statuses.new(:status => 'submitted')
        @status.save

        #Notify
        Notifier.cr_notify(current_user, @change_request, 'new_cr')
        Thread.new do
          UserMailer.notif_email(@change_request.user, @change_request, @status).deliver
          ActiveRecord::Base.connection.close
        end
        #SendNotifEmailJob.set(wait: 20.seconds).perform_later(@change_request.user, @change_request, @status)
        flash[:create_cr_notice] = 'Change request was successfully created.'
        format.html { redirect_to @change_request }
        format.json { render :show, status: :created, location: @change_request }
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = []
        @users = User.all.collect{|u| [u.name, u.id]}
        @approvers = User.approvers.collect{|u| [u.name, u.id]}
        @current_collaborators = params[:collaborators_list]? params[:collaborators_list] : []
        @current_implementers = params[:implementers_list]? params[:implementers_list] : []
        @current_testers = params[:testers_list]? params[:testers_list] : []
        @current_approvers = params[:approvers_list]? params[:approvers_list] : []

        format.html { render :new }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:search].blank?
      redirect_to change_requests_path
    end
    @results = ChangeRequest.solr_search{fulltext params[:search]}.results
  end

  def update

    #Remove all current approvals assigning
    @change_request.approvals.delete_all

    #Populating approvers list
    @approvers_list = params[:approvers_list]? params[:approvers_list] : []
    @change_request.approvals = []
    @approvers_list.each do |approver|
      @tmp_user = User.find(approver)
      @approval = Approval.create(user: @tmp_user, change_request: @change_request)
      @change_request.approvals << @approval
    end

    #Populating testers list
    @testers_list = params[:testers_list]? params[:testers_list] : []
    @change_request.testers = []
    @testers_list.each do |tester_id|
      @change_request.testers << User.find(tester_id)
    end

    #Populating implementers list
    @implementers_list = params[:implementers_list]? params[:implementers_list] : []
    @change_request.implementers = []
    @implementers_list.each do |implementer_id|
      @change_request.implementers << User.find(implementer_id)
    end

    respond_to do |format|
      if @change_request.update(change_request_params)

        #Collaborators section
        @collaborators_list = params[:collaborators_list]? params[:collaborators_list] : []
        @change_request.collaborators.delete_all
        @collaborators_list.each do |collaborator_id|
          @change_request.collaborators << User.find(collaborator_id)
        end

        Notifier.cr_notify(current_user, @change_request, 'update_cr')
        flash[:update_cr_notice] = 'Change request was successfully updated.'
        format.html { redirect_to @change_request }
        format.json { render :show, status: :ok, location: @change_request }
      else
        @current_tags = @change_request.tag_list
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_collaborators = @change_request.implementers.collect{|u| u.id}
        @current_approvers = @change_request.approvals.collect{|a| a.user.name}
        @current_implementers = @change_request.implementers.collect{|u| u.id}
        @current_testers = @change_request.testers.collect{|u| u.id}
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
      params.require(:change_request).permit(:change_summary, :priority, :db,
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

end
