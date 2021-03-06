#
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_user
  before_action :check_pending_user
  before_action :set_paper_trail_whodunnit
  require 'notifier.rb' # Omg

  def check_user
    if current_user.present?
      token_required!
      approved_account
    end
  end

  def token_required!
    if current_user.token.nil?
      sign_out current_user
    end
  end

  def after_sign_in_path_for(resource)
    return_url = stored_location_for(resource) || change_requests_path
    if current_user.pending?
      return_url = register_path
      flash[:alert] = "Please fill the form correctly to propose your access request to approver."
    end
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

  private

  def approved_account
    unless current_user.approved? || current_user.pending?
      flash_message = if current_user.need_approvals?
        'Your account is not yet approved to open Vision'
      elsif current_user.rejected?
        'Sorry, your access request to Vision is rejected.'
      end
      flash[:alert] = flash_message

      sign_out current_user
      redirect_to signin_path    
    end
  end

  def check_pending_user
    if current_user.present? && current_user.pending?
      redirect_to register_path
    end
  end

end
