#
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_required, except: [:new, :create]
  before_action :check_approved_user, only: [:new, :create]
  skip_before_action :admin_required, only:[:approver]
  skip_before_action :check_user, only: [:new, :create]


  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page])
             .per(params[:per_page])
  end

  def new
    @access_request = AccessRequest.new
  end

  def create
    request_type_default = 'Create'
    access_type_default = 'Permanent'
    AccessRequest.transaction do
      @access_request = current_user.AccessRequests.build(
        register_user_params.merge({
          :request_type => request_type_default,
          :access_type => access_type_default,
          :employee_email_address => current_user.email
        })
      )

      approver_id = User.find_by_email(User::APPROVER_EMAIL).id
      if approver_id.nil?
        flash[:error] = 'An error occured.'
        redirect_to signin_path
      else
        approvers = Array.wrap([ approver_id ])
        @access_request.set_approvers(approvers)
        if @access_request.save
          @access_request.submit!
          current_user.is_approved = User::WAITING_FOR_APPROVAL
          current_user.save
          sign_out current_user
          SlackNotif.new.notify_new_access_request(@access_request)
          flash[:success] = 'Request has been created and waiting for approval. You\'ll get notification once its approved'
          redirect_to signin_path
        else
          render 'new'
        end
      end     
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
    @user.update_attribute(:is_approved, 3)
    flash[:success] = 'User approved succesfully'
    UserRequestMailer.approve_email(@user).deliver_now
    redirect_to users_path
  end

  def reject_user
    @user = User.find params[:id]
    @user.update_attribute(:is_approved, 0)
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


  def check_approved_user
    case current_user.is_approved
      when User::REJECTED
      when User::WAITING_FOR_APPROVAL
        redirect_to signin_path
      when User::APPROVED
        redirect_to root_path
    end
  end
end
