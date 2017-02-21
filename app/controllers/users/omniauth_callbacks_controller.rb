# 'app/controllers/users/omniauth_callbacks_controller.rb'
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])
    @user.token = request.env['omniauth.auth'][:credentials][:token]
    @user.refresh_token =request.env['omniauth.auth'][:credentials][:refresh_token]
    @user.expired_at = Time.at(request.env['omniauth.auth'][:credentials][:expires_at]).to_datetime
    @user.valid?
    @user.save
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      if @user.use_company_email?
        err_message = 'Please use company email'
      else
        err_message = 'Authentication failed!'
      end
      redirect_to root_path, flash: { alert: err_message }
    end
  end

  def failure
    redirect_to root_path
  end
end
