require 'slack_notif.rb'

# class ChangeRequestSlackNewJob < ActiveJob::Base
class NewChangeRequestSlackNotificationJob < ActiveJob::Base
  include SuckerPunch::Job 

  def perform(change_request)
    ActiveRecord::Base.connection_pool.with_connection do
      SlackNotif.new.notify_new_cr change_request
    end
  end
end
