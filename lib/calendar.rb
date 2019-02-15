require 'google/apis/calendar_v3'
require 'user_credential.rb'

class Calendar
  include Rails.application.routes.url_helpers

  def set_cr(user, change_request)
    event = build_event_from_cr(change_request)
    set_event(user, event, change_request.google_event_id)
  end

  def build_event_from_cr(change_request)
    users = [change_request.user] + change_request.collaborators + change_request.implementers
    event = Google::Apis::CalendarV3::Event.new
    event.summary = change_request.change_summary
    event.description = "CR: #{change_request_url(change_request)}\nPIC: #{change_request.requestor_name}"
    event.location = ''
    event.start = Google::Apis::CalendarV3::EventDateTime.new(date_time: change_request.schedule_change_date.to_datetime)
    event.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: change_request.planned_completion.to_datetime)
    event.attendees = users.map do |user|
      Google::Apis::CalendarV3::EventAttendee.new(email: user.email)
    end
    event
  end

  def set_event(user, event, event_id=nil)
    service = Google::Apis::CalendarV3::CalendarService.new
    user_credential = UserCredential.new(user.refresh_token, ["profile,email,https://www.googleapis.com/auth/calendar,https://www.googleapis.com/auth/calendar.events"])
    service.authorization = user_credential.get_credentials
    calendar_id = ENV['DEPLOY_CALENDAR_ID']
    if event_id.nil?
      service.insert_event(calendar_id, event, send_notifications: true)
    else
      service.update_event(calendar_id, event_id, event, send_notifications: true)
    end
  end


end
