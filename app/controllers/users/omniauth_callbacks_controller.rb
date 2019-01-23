# 'app/controllers/users/omniauth_callbacks_controller.rb'
require 'register_service'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    is_new_user, @user = User.from_omniauth(request.env['omniauth.auth'])
    @user.token = request.env['omniauth.auth'][:credentials][:token]
    @user.refresh_token = request.env['omniauth.auth'][:credentials][:refresh_token]
    @user.expired_at = Time.at(request.env['omniauth.auth'][:credentials][:expires_at]).to_datetime
    is_signin, redirect_path, flash_messages, trigger_event = create_or_signin_user(is_new_user, @user)
    if is_signin?
      if trigger_event?
        sign_in @user, event: :authentication
      else
        sign_in @user
      end
    end
    redirect_to redirect_path, flash: flash_messages    
  end

  def failure
    redirect_to root_path
  end


end
