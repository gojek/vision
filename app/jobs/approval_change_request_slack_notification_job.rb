require 'slack_notif.rb'

# class ChangeRequestSlackApprovalJob < ActiveJob::Base
class ApprovalChangeRequestSlackNotificationJob < ApplicationJob
  include SuckerPunch::Job 

  def perform(change_request, approval)
    ApplicationRecord.connection_pool.with_connection do
      SlackNotif.new.notify_approval_status_cr(change_request, approval)
    end
  end
end
