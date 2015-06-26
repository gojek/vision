# 'app/controllers/users/omniauth_callbacks_controller.rb'
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to root_path, flash: { error: 'Authentication failed!' }
    end
  end

  def failure
    redirect_to root_path
  end
end
