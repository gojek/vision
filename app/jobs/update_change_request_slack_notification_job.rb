require 'slack_notif.rb'

# class ChangeRequestSlackUpdateJob < ActiveJob::Base
class UpdateChangeRequestSlackNotificationJob < ApplicationJob
  include SuckerPunch::Job 

  def perform(change_request)
    ApplicationRecord.connection_pool.with_connection do
      SlackNotif.new.notify_update_cr change_request
    end
  end
end
