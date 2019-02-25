# frozen_string_literal: true

require 'google/apis/calendar_v3'

class Event < Google::Apis::CalendarV3::Event
  attr_writer :saved
  attr_accessor :error_messages

  def initialize
    @saved = false
    @error_messages = nil
  end

  def self.build_event_from_change_request(change_request)
    routes = Rails.application.routes.url_helpers
    event = Event.new
    users = [change_request.user] + change_request.collaborators + change_request.implementers
    event.id ||= change_request.google_event_id
    event.summary = change_request.change_summary
    event.description = "CR: #{routes.change_request_url(change_request)}\nPIC: #{change_request.requestor_name}"
    event.location = ''
    event.start = Google::Apis::CalendarV3::EventDateTime.new(
      date_time: change_request.schedule_change_date.to_datetime
    )
    event.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: change_request.planned_completion.to_datetime)
    event.attendees = users.map do |user|
      Google::Apis::CalendarV3::EventAttendee.new(email: user.email)
    end
    event
  end

  def success?
    @saved
  end
end
