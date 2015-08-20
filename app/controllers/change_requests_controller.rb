class ChangeRequestsController < ApplicationController
  before_action :set_change_request, only: [:show, :edit, :update, :destroy, :approve, :reject, :edit_grace_period_notes, :edit_implementation_notes, :print]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]
  before_action :not_closed_required, only: [:destroy]
  before_action :submitted_required, only: [:edit]

  def index
    if params[:tag]
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).tagged_with(params[:tag]).order(created_at: :desc).page(params[:page]).per(params[:per_page])
    else
      #populate all CR if release_manager
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end
  end

  def show
    @version = @change_request.versions
    @change_request_status = ChangeRequestStatus.new
    approve = Approver.where(change_request_id: @change_request.id).where(user_id: current_user.id).first
    if(approve == nil) 
      @approved = nil
    else
      @approved = approve.approve
    end
  end

  def new
    @change_request = ChangeRequest.new
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @users = User.all.collect(&:name)
    @current_tags = []
    @current_collaborators = []
  end

  def edit
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = @change_request.tag_list
    @users = User.all.collect(&:name)
    @current_collaborators = @change_request.collaborators.collect(&:name)
  end

  def edit_grace_period_notes
  end
  
  def edit_implementation_notes
  end

  def print
    render layout:false
  end

  def create
    binding.pry
    @change_request = current_user.ChangeRequests.build(change_request_params)
    @collaborators_list = params[:collaborators_list]? params[:collaborators_list] : []
    @collaborators_list.each do |collaborator|
      @change_request.collaborators << User.find_by(name: collaborator)
    end
    respond_to do |format|
      if @change_request.save
        @approvers = User.where(role: "approver")
        @status = @change_request.change_request_statuses.new(:status => 'submitted')
        @status.save
        @approvers.each do |approver|
          @approval = Approver.new
          @approval.user_id = approver.id
          @approval.change_request_id = @change_request.id
          @approval.save
        end

        #Thread.new do
         # UserMailer.notif_email(@change_request.user, @change_request, @status).deliver
          #ActiveRecord::Base.connection.close
        #end
        #SendNotifEmailJob.set(wait: 20.seconds).perform_later(@change_request.user, @change_request, @status)
        flash[:create_cr_notice] = 'Change request was successfully created.'
        format.html { redirect_to @change_request }
        format.json { render :show, status: :created, location: @change_request }
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = []
        @users = User.all.collect(&:name)
        @current_collaborators = []
        format.html { render :new }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @change_request.update(change_request_params)
        @collaborators_list = params[:collaborators_list]? params[:collaborators_list] : []
        @change_request.collaborators.delete_all
        @collaborators_list.each do |collaborator|
          @change_request.collaborators << User.find_by(name: collaborator)
        end
        @change_request.save
        flash[:update_cr_notice] = 'Change request was successfully updated.'
        format.html { redirect_to @change_request }
        format.json { render :show, status: :ok, location: @change_request }
      else
        @current_tags = @change_request.tag_list
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @users = User.all.collect(&:name)
        @current_collaborators = @change_request.collaborators.collect(&:name)
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
    approver = Approver.where(change_request_id: @change_request.id).where(user_id: current_user.id)
    approver.update_all(:approve => true)
    if approver.empty?
      flash[:not_eligible_notice] = 'You are not eligible to approve this Change Request'
    else
      flash[:status_changed_notice] = 'Change Request Approved'
    end
    redirect_to @change_request
  end

  def reject
    approver = Approver.where(change_request_id: @change_request.id).where(user_id: current_user.id)
    reject_reason = params["reject_reason"]
    if approver.empty?
      flash[:not_eligible_notice] = 'You are not eligible to reject this Change Request'
    elsif reject_reason.blank?
      flash[:reject_reason_notice] = 'You must fill reject reason'
    else
      approver.update_all(:approve => false, :reject_reason => reject_reason)
      flash[:status_changed_notice] = 'Change Request Rejected'
    end
    redirect_to @change_request
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
      params.require(:change_request).permit(:change_summary, :priority, :db, :os, :net, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :note, :analysis, :solution, :impact, :scope, :design, :backup,:testing_environment_available, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes, :requestor_name,
        :definition_of_success, :definition_of_failed, :category_application, :category_network_equipment,:category_server, :category_user_access,
        :category_other,:other_dependency,:solving_duration, :type_security_update,:type_install_uninstall, :type_configuration_change, :type_emergency_change, :type_other,
        implementers_attributes: [:id, :name, :position, :_destroy], testers_attributes: [:id, :name, :position, :_destroy], :tag_list => [], :collaborators_list => [])
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
