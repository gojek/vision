require 'slack_notif.rb'

class IncidentReportNewSlackNotifJob < ActiveJob::Base

  include SuckerPunch::Job

  def perform(incident_report)
    SlackNotif.new.notify_new_ir incident_report
  end
end
