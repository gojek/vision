# frozen_string_literal: true

require 'event'
require 'google_client'

class CalendarService
  def initialize(user)
    @service = GoogleClient.new user
  end

  def assign_event_for(change_request)
    event = @service.upsert_event(Event.build_event_from_change_request(change_request))
    change_request.google_event_id = event.id
    event
  end
end
