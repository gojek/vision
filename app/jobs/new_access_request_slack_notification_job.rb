require 'slack_notif.rb'

class NewAccessRequestSlackNotificationJob < ActiveJob::Base

  include SuckerPunch::Job

  def perform(access_request)
    SlackNotif.new.notify_new_access_request access_request
  end
end
