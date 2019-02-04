# frozen_string_literal: true

class Calendar
  include Rails.application.routes.url_helpers

  def set_cr(user, change_request)
    event = build_event_from_cr(change_request)
    set_event(user, event, change_request.google_event_id)
  end

  def build_event_from_cr(change_request)
    users = [change_request.user] + change_request.collaborators + change_request.implementers
    {
      'summary' => change_request.change_summary,
      'description' => "CR: #{change_request_url(change_request)}\nPIC: #{change_request.requestor_name}",
      'location' => '',
      'start' => { 'dateTime' => change_request.schedule_change_date.to_datetime },
      'end' => { 'dateTime' => change_request.planned_completion.to_datetime },
      'attendees' => users.collect { |user| { 'email' => user.email } }
    }
  end

  def set_event(user, event, event_id = nil)
    client = Google::APIClient.new
    client.authorization.access_token = user.token
    service = client.discovered_api('calendar', 'v3')

    parameters = {
      'calendarId' => ENV['DEPLOY_CALENDAR_ID'],
      'sendNotifications' => true
    }

    if event_id.nil?
      api_method = service.events.insert
    else
      api_method = service.events.update
      parameters['eventId'] = event_id
    end

    client.execute(api_method: api_method,
                   parameters: parameters,
                   body: JSON.dump(event),
                   headers: { 'Content-Type' => 'application/json' })
  end
end
