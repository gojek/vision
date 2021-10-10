class UserMailer < ApplicationMailer
  default from: "visionopensource2021@gmail.com"

  def notif_email(user, change_request, status)
    @user = user
    @change_request = change_request
    @status = status
    @url = change_request_url(@change_request)
    @state = @status.status
    @reason = @status.reason
    @summary = change_request.change_summary
    unless change_request.schedule_change_date.nil?
      @deploy  = change_request.schedule_change_date.to_s(:long)
    end

    @recipients = change_request.approvals.collect{|a| a.user.email}
    if @recipients.count > 1
      approvers = @recipients.join(",")
    else
      approvers = @recipients
    end
    mail(to: [@user.email,approvers], subject:'Change Request Status Changed')
  end
end
