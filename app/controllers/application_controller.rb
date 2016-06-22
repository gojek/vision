#
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_user
  require 'notifier.rb'

  def check_user
  	token_required! unless current_user==nil
  end

  def token_required!
  	sign_out current_user unless current_user.token != nil
  end


end
