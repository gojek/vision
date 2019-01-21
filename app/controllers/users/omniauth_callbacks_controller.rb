# 'app/controllers/users/omniauth_callbacks_controller.rb'
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    is_new_user, @user = User.from_omniauth(request.env['omniauth.auth'])
    @user.token = request.env['omniauth.auth'][:credentials][:token]
    @user.refresh_token = request.env['omniauth.auth'][:credentials][:refresh_token]
    @user.expired_at = Time.at(request.env['omniauth.auth'][:credentials][:expires_at]).to_datetime
    begin
      @user.valid?
      @user.save
      if @user.persisted?
        if is_new_user || @user.is_approved == User::NOT_YET_FILL_THE_FORM
          sign_in @user
          flash[:alert] = 'Please fill the form to requesting your access.'
          redirect_to register_path
        elsif @user.is_approved == User::WAITING_FOR_APPROVAL
          flash[:alert] = 'Your account is not yet approved to open Vision'
          redirect_to signin_path
        elsif @user.is_approved == User::REJECTED
          flash[:alert] = 'Sorry, your access request to Vision is rejected.'
          redirect_to signin_path
        else
          sign_in_and_redirect @user, event: :authentication
        end
      else
        if !@user.use_company_email?
          err_message = 'Please use company email'
        else
          err_message = 'Authentication failed!'
        end
        redirect_to root_path, flash: { alert: err_message }
      end
    rescue ActiveRecord::ActiveRecordError
      flash[:error] = 'An error occured. Please try again.'
      redirect_to root_path
    end
    
  end

  def failure
    redirect_to root_path
  end


end
