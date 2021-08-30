# frozen_string_literal: true

require 'google/apis/calendar_v3'
require 'user_credential'

class GoogleClient
  def initialize(user)
    @user = user
  end

  def upsert_event(event)
    calendar_id = ENV['DEPLOY_CALENDAR_ID']
    returned_event = if event.id.present?
                       calendar_service.update_event(calendar_id, event.id, event, send_notifications: true)
                     else
                       calendar_service.insert_event(calendar_id, event, send_notifications: true)
                     end
    event.id = returned_event.id
    event.saved = true
    event
  rescue StandardError => e
    event.error_messages = e.to_s
    event
  end

  private

  def credentials
    @credentials ||= UserCredential.new(@user).authorize
  end

  def calendar_service
    @calendar_service ||= Google::Apis::CalendarV3::CalendarService.new
    @calendar_service.authorization = credentials
    @calendar_service
  end
end
