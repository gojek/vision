#
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_user
  require 'notifier.rb' # Omg

  def check_user
    token_required! unless current_user.nil?
  end

  def token_required!
    if current_user.token.nil? or current_user.expired_session?
      sign_out current_user
    elsif current_user.expired?
      current_user.refresh!
    end
  end

  def after_sign_in_path_for(resource)
    session[:first_time] = true
    return_url = stored_location_for(resource) || change_requests_path
    logger.info "Returning User to.......... #{return_url}"
    return_url
  end

  def stream(filename, content_type, enumerator)
    self.response.headers["Content-Type"] ||= "#{content_type}"
    self.response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
    self.response.headers["Content-Transfer-Encoding"] = "binary"
    self.response.headers["Last-Modified"] = Time.now.ctime.to_s

    self.response_body = enumerator
  end
end
