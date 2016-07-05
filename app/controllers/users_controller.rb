#
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_required
  skip_before_action :admin_required, only:[:approver]

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page])
             .per(params[:per_page])
  end

  def edit
    @user = User.find params[:id]

  end

  def update
    @user = User.find params[:id]
    @user.is_admin = params[:is_admin]
    @user.save
    if @user.update(update_user_params)
      flash[:user_notice] = 'User updated succesfully'
      redirect_to users_path
    else
      render action: 'edit'
    end
  end

  def lock_user
    @user = User.find params[:id]
    @user.update_attribute(:locked_at, Time.current)
    flash[:user_notice] = 'User locked succesfully'
    redirect_to users_path
  end

  def unlock_user
    @user = User.find params[:id]
    @user.update_attribute(:locked_at, nil)
    flash[:user_notice] = 'User unlocked succesfully'
    redirect_to users_path
  end

  private

  def admin_required
    current_user.is_admin || current_user.role == 'release_manager' || (redirect_to root_path)
  end

  def update_user_params
    params.require(:user).permit(:email, :role, :position, :is_admin)
  end
end
