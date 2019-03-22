require 'slack_notif.rb'

class NewAccessRequestSlackNotificationJob < ActiveJob::Base

  include SuckerPunch::Job

  def perform(access_request)
    ActiveRecord::Base.connection_pool.with_connection do
      SlackNotif.new.notify_new_ar access_request
    end
  end
end
