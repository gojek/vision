require 'slack_notif.rb'

class ChangeRequestSlackUpdateJob < ActiveJob::Base
  include SuckerPunch::Job 

  def perform(change_request)
    SlackNotif.new.notify_update_cr change_request
  end
end
