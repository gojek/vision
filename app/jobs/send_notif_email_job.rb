class SendNotifEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user, change_request, status)
  	@user = user
  	@change_request = change_request
  	@status = status
  	UserMailer.notif_email(@user, @change_request, @status).deliver_later
    # Do something later
  end
end
