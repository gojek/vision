class NotificationsController < ApplicationController
  require 'notifier.rb'

  def clear_notifications
    Notifier.mark_all_as_read(current_user)
    redirect_to request.referer
  end
end
