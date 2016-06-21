class UserMailer < ApplicationMailer
  default from: "narendra.hanif@veritrans.co.id"

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
  def cab_email(cab)
    @date = cab.meet_date.to_s(:long)
    @room = cab.room
    @notes = cab.notes
    @change_requests = cab.change_requests
    @all_recepients = []
    @change_requests.each do |change_request|
      @all_recepients.push(change_request.user.email)
      @all_recipients.push(change_request.approvals.collect{|a| a.user.email})
    end
    all_rec = @all_recepients.uniq.join(",")
    mail(to: all_rec, subject:'New CAB Meeting')
  end

end
