class ChangeRequestsController < ApplicationController
  before_action :set_change_request, only: [:show, :edit, :update, :destroy, :approve, :reject, :edit_grace_period_notes, :schedule, :deploy, :rollback, :cancel, :close, :submit, :final_reject]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]
  before_action :submitted_required, only: [:edit]
  before_action :release_manager_required, only: [:schedule, :deploy, :rollback, :cancel, :close]
  autocomplete :tag, :name, :class_name => 'ActsAsTaggableOn::Tag'
  QUOROM_APPROVERS = 2
  def index
    if params[:tag]
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).tagged_with(params[:tag]).order(created_at: :desc).page(params[:page]).per(params[:per_page])
    elsif(current_user.role=='requestor')
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).where(user_id: current_user.id).order(created_at: :desc).page(params[:page]).per(params[:per_page])
    elsif(current_user.role=='approver')
      @q = ChangeRequest.ransack(params[:q])
      @change_requests = @q.result(distinct: true).joins(:approvers).where(approvers: {user_id: current_user.id}).order(created_at: :desc).page(params[:page]).per(params[:per_page])
    else
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
  end

  def edit
  end

  def edit_grace_period_notes
  end

  def create
    @change_request = current_user.ChangeRequests.build(change_request_params)
    respond_to do |format|
      if @change_request.save
        @approvers = User.where(role: "approver")
        @approvers.each do |approver|
          @approval = Approver.new
          @approval.user_id = approver.id
          @approval.change_request_id = @change_request.id
          @approval.save
        end
        format.html { redirect_to @change_request, notice: 'Change request was successfully created.' }
        format.json { render :show, status: :created, location: @change_request }
      else
        format.html { render :new }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @change_request.update(change_request_params)
        format.html { redirect_to @change_request, notice: 'Change request was successfully updated.' }
        format.json { render :show, status: :ok, location: @change_request }
      else
        format.html { render :edit }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @change_request.destroy
    respond_to do |format|
      format.html { redirect_to change_requests_url, notice: 'Change request was successfully destroyed.' }
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
      flash[:notice] = 'You are not eligible to approve this Change Request'
    else
      flash[:notice] = 'Change Request Approved'
    end
    redirect_to @change_request
  end

  def reject
    approver = Approver.where(change_request_id: @change_request.id).where(user_id: current_user.id)
    approver.update_all(:approve => false)
    if approver.empty?
      flash[:notice] = 'You are not eligible to reject this Change Request'
    else
      flash[:notice] = 'Change Request Rejected'
    end
    redirect_to @change_request
  end
  def schedule
    @change_request.schedule!

    redirect_to @change_request
  end
  def deploy
    @change_request.deploy!
    redirect_to @change_request
  end
  def rollback
    @change_request.rollback!
    @change_request.update(rollback_params)
    redirect_to @change_request
  end
  def cancel
    @change_request.cancel!
    @change_request.update(cancel_params)
    redirect_to @change_request
  end
  def close
   @change_request.close!
    @change_request.update(close_params)
    redirect_to @change_request
  end  
  def final_reject
    @change_request.reject!
    @change_request.update(reject_params)
    redirect_to @change_request
  end
  def submit
    @change_request.submit!

    redirect_to @change_request
  end
  private
    def set_change_request
      if params[:tag]
        @change_requests = ChangeRequest.tagged_with(params[:tag])
      elsif params[:change_request_id]
        @change_request = ChangeRequest.find(params[:change_request_id])
      else
        @change_request = ChangeRequest.find(params[:id])
      end
    end

    def change_request_params
      params.require(:change_request).permit(:tag_list, :change_summary, :priority, :db, :os, :net, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :note, :analysis, :solution, :impact, :scope, :design, :backup,:testing_environment_available, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes, :requestor_name,
        implementers_attributes: [:id, :name, :position, :_destroy], testers_attributes: [:id, :name, :position, :_destroy])
    end

    def owner_required
      redirect_to change_requests_url if
      current_user != @change_request.user && !current_user.is_admin
    end
    def release_manager_required
      redirect_to change_request_path if 
      current_user.role != 'release_manager'
    end
    def submitted_required
      if @change_request.closed?
        redirect_to change_requests_path
      else
        redirect_to graceperiod_path if !@change_request.submitted?
      end
    end
    def reject_params
      params.require(:change_request).permit(:reject_note)
    end
    def rollback_params
      params.require(:change_request).permit(:rollback_note)
    end
    def cancel_params
      params.require(:change_request).permit(:cancel_note)
    end
    def close_params
      params.require(:change_request).permit(:close_note)
    end
end
