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

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = 'New user registered succesfully'
      
      redirect_to register_path
    else
      render action: 'new'
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    if @user.update(update_user_params)
      flash[:notice] = 'User updated succesfully'
      UserMailer.notif_email(@user).deliver
      redirect_to users_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy
    flash[:notice] = 'User deleted succesfully'
    redirect_to users_path
  end

  def lock_user
    @user = User.find params[:id]
    @user.update_attribute(:locked_at, Time.current)
    flash[:notice] = 'User locked succesfully'
    redirect_to users_path
  end

  def unlock_user
    @user = User.find params[:id]
    @user.update_attribute(:locked_at, nil)
    flash[:notice] = 'User unlocked succesfully'
    redirect_to users_path
  end

  private

  def admin_required
    current_user.is_admin || current_user.role == 'release_manager' || (redirect_to root_path)
  end

  def update_user_params
    params.require(:user).permit(:email, :role, :position)
  end
end
