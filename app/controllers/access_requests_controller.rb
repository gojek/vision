class AccessRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_access_request, except: [:index, :new, :create]
  before_action :authorized_to_change_status, only: [:cancel, :close]
  before_action :set_access_request_reason, only: [:cancel, :close]
  before_action :set_access_request_approval, only: [:approve, :reject]
  before_action :set_users_and_approvers, only: [:new, :edit]

  def index
    @q = AccessRequest.ransack(params[:q])
    @access_requests = @q.result(distinct: true).order(id: :desc)

    @access_requests = @access_requests.page(params[:page]).per(params[:per_page])
  end

  def new
    @access_request = AccessRequest.new
  end

  def create
    AccessRequest.transaction do
      @access_request = current_user.AccessRequests.build(access_request_params)
      assign_collaborators_and_approvers
      if @access_request.save
        if @access_request.draft?
          @access_request.submit!
        end
        flash[:success] = 'Change request was successfully created.'
      else
        @access_request.save(validate: false)
        flash[:notice] = 'Access request was created as a draft.'
        flash[:invalid] = @access_request.errors.full_messages
      end
    end
    
    redirect_to @access_request
  end

  def show
    @access_request_status = AccessRequestStatus.new
  end

  def edit
  end

  def update
    AccessRequest.transaction do
      assign_collaborators_and_approvers

      if @access_request.update(access_request_params)
        if @access_request.draft?
          @access_request.submit! 
        end
        flash[:success] = 'Change request was successfully edited.'
      else
        @access_request.save(:validate=> false)
        flash[:notice] = 'Access request was edited as a draft.'
        flash[:invalid] = @access_request.errors.full_messages
      end
    end
    
    redirect_to @access_request
  end

  def destroy
    @access_request.destroy
    respond_to do |format|
      flash[:success] = 'Access request was successfully destroyed.'
      format.html { redirect_to access_requests_url }
      format.json { head :no_content }
    end
  end

  def cancel
    if @access_request.may_cancel?
      unless @access_request.cancel!
        flash[:alert] = @access_request.errors.full_messages.to_sentence
      end
    else
      flash[:alert] = 'AR can\'t be cancelled'
    end
    redirect_to @access_request
  end

  def close
    if @access_request.may_close? && @access_request.closeable?
      unless @access_request.close!
        flash[:alert] = @access_request.errors.full_messages.to_sentence
      end
    else
      flash[:alert] = 'AR can\'t be closed'
    end
    redirect_to @access_request
  end

  def approve
    if @approval.update(approved: true, notes: params["notes"])
      flash[:success] = 'Access Request approved'
    else
      flash[:notice] = @approval.errors.full_messages.to_sentence
    end
    redirect_to @access_request
  end

  def reject
    if @approval.update(approved: false, notes: params["notes"])
      flash[:success] = 'Access Request rejected'
    else
      flash[:notice] = @approval.errors.full_messages.to_sentence
    end
    redirect_to @access_request
  end

  private

    def set_access_request
      if params[:access_request_id]
        @access_request = AccessRequest.find(params[:access_request_id])
      else
        @access_request = AccessRequest.find(params[:id])
      end
    end

    def access_request_params
      params
        .require(:access_request)
        .permit(
          :request_type,
          :access_type,
          :start_date,
          :end_date,
          :employee_name, 
          :employee_position,
          :employee_email_address,
          :employee_department,
          :employee_phone,
          :employee_access, 
          :fingerprint_business_area,
          :fingerprint_business_operations,
          :fingerprint_it_operations,
          :fingerprint_server_room, 
          :fingerprint_archive_room,
          :fingerprint_engineering_area,
          :corporate_email,
          :internet_access,
          :slack_access, 
          :admin_tools,
          :vpn_access,
          :github_gitlab,
          :exit_interview,
          :access_card,
          :parking_cards,
          :id_card,
          :name_card, 
          :insurance_card,
          :cash_advance,
          :password_reset,
          :user_identification,
          :asset_name
      )
    end

    def set_access_request_reason
      @access_request.reason = params[:access_request_status][:reason]
    end

    def set_users_and_approvers
      @users = User.all.collect{|u| [u.name, u.id]}
      @approvers = User.approvers_ar.collect{|u| [u.name, u.id] if u.id != current_user.id }
    end

    def set_access_request_approval
      @approval = AccessRequestApproval.find_by(access_request_id: @access_request.id, user_id: current_user.id)
      unless @approval
        flash[:alert] = 'You are not eligible to approve this Access Request'
        redirect_to @access_request
      end
    end

    def authorized_to_change_status
      unless @access_request.actionable?(current_user)
        flash[:alert] = 'You are not eligible to change the status of this Access Request'
        redirect_to @access_request
      end
    end

    def assign_collaborators_and_approvers
      @current_approvers = Array.wrap(params[:approvers_list])
      @current_collaborators = Array.wrap(params[:collaborators_list])
      @access_request.set_approvers(@current_approvers)
      @access_request.set_collaborators(@current_collaborators)
    end
end
