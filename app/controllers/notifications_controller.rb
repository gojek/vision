class NotificationsController < ApplicationController
  require 'notifier.rb'

  def index
      @active = params[:type]
      @notifications = current_user.notifications
      @new_cr = @notifications.new_cr
      @update_cr = @notifications.update_cr
      @approved = @notifications.approved
      @rejected = @notifications.rejected
      @final_rejected = @notifications.final_rejected
      @cancelled = @notifications.cancelled
      @scheduled = @notifications.scheduled
      @deployed = @notifications.deployed
      @closed = @notifications.closed
      @rollbacked = @notifications.rollbacked
      @comment = @notifications.comment
      @new_ir = @notifications.new_incident
      @resolved_ir = @notifications.resolved

      @have_cr_notif = !@notifications.cr.empty?
      @have_ir_notif = !@notifications.ir.empty?

  end

  def clear_notifications
    Notifier.mark_all_as_read(current_user)
    redirect_to request.referer
  end
end
