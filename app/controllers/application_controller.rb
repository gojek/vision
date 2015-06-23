class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery with: :exception
  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :role
  end
end
