#
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_required, except: [:new, :create]
  before_action :redirect_non_pending_user, only: [:new, :create]
  skip_before_action :admin_required, only:[:approver]
  skip_before_action :check_pending_user, only: [:new, :create]


  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page])
             .per(params[:per_page])
             .order("created_at DESC")
  end

  def new
    @access_request = AccessRequest.new
  end

  def create
    approver_user = User.find_by_email(User::APPROVER_EMAIL)
    @access_request = AccessRequest.create_for_new_registration_user(current_user, register_user_params, approver_user)
    if @access_request.errors.present?
      render 'new'  
    else
      @access_request.submit!
      current_user.need_approvals!
      current_user.save
      sign_out current_user
      NewAccessRequestSlackNotificationJob.perform_async(@access_request)          
      flash[:success] = 'Request has been created and waiting for approval. You\'ll get notification once its approved'
      redirect_to signin_path
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.is_admin = params[:is_admin]
    @user.save
    if @user.update(update_user_params)
      flash[:success] = 'User updated succesfully'
      redirect_to users_path
    else
      render action: 'edit'
    end
  end

  def lock_user
    @user = User.find params[:id]
    @user.update_attribute(:locked_at, Time.current)
    flash[:success] = 'User locked succesfully'
    redirect_to users_path
  end

  def unlock_user
    @user = User.find params[:id]
    @user.update_attribute(:locked_at, nil)
    flash[:success] = 'User unlocked succesfully'
    redirect_to users_path
  end

  def approve_user
    @user = User.find params[:id]
    @user.approved!
    flash[:success] = 'User approved succesfully'
    UserRequestMailer.approve_email(@user).deliver_now
    redirect_to users_path
  end

  def reject_user
    @user = User.find params[:id]
    @user.rejected!
    flash[:success] = 'User rejected succesfully'
    UserRequestMailer.reject_email(@user).deliver_now
    redirect_to users_path
  end

  private

  def register_user_params
    params.require(:access_request).permit(
      :employee_name,
      :employee_position,
      :employee_department,
      :business_justification,
      :employee_phone,
    )
  end

  def admin_required
    current_user.is_admin || current_user.role == 'release_manager' || (redirect_to root_path)
  end

  def update_user_params
    params.require(:user).permit(:email, :role, :position, :is_admin)
  end


  def redirect_non_pending_user
    if current_user.rejected? || current_user.need_approvals?
      redirect_to signin_path
    elsif current_user.approved?
      redirect_to root_path
    end
  end
end
