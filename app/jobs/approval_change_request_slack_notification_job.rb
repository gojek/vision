require 'slack_notif.rb'

# class ChangeRequestSlackApprovalJob < ActiveJob::Base
class ApprovalChangeRequestSlackNotificationJob < ActiveJob::Base
  include SuckerPunch::Job 

  def perform(change_request, approval)
  	SlackNotif.new.notify_approval_status_cr(change_request, approval)
  end
end
