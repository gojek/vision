require 'slack_notif.rb'

class NewAccessRequestSlackNotificationJob < ApplicationJob

  include SuckerPunch::Job

  def perform(access_request)
    ApplicationRecord.connection_pool.with_connection do
      SlackNotif.new.notify_new_ar access_request
    end
  end
end
