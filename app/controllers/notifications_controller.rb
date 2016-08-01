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

      @tabactive = Array.new(11,false)
      @have_cr_notif = true

      if !@new_cr.empty?
        @tabactive[0] = true
      elsif !@update_cr.empty?
        @tabactive[1] = true
      elsif !@approved.empty?
        @tabactive[2] = true
      elsif !@rejected.empty?
        @tabactive[3] = true
      elsif !@final_rejected.empty?
        @tabactive[4] = true
      elsif !@cancelled.empty?
        @tabactive[5] = true
      elsif !@scheduled.empty?
        @tabactive[6] = true
      elsif !@deployed.empty?
        @tabactive[7] = true
      elsif !@closed.empty?
        @tabactive[8] = true
      elsif !@rollbacked.empty?
        @tabactive[9] = true
      elsif !@comment.empty?
        @tabactive[10] = true
      else
        @have_cr_notif = false
      end

      @iractive = Array.new(2,false)
      @have_ir_notif = true

      if !@new_ir.empty?
        @iractive[0] = true
      elsif !@resolved_ir.empty?
        @iractive[1] = true
      else
        @have_ir_notif = false
      end
  end

  def clear_notifications
    Notifier.mark_all_as_read(current_user)
    redirect_to request.referer
  end
end
