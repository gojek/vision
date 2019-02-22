# frozen_string_literal: true

require 'googleauth'

class UserCredential
  def initialize(refresh_token)
    @refresh_token = refresh_token
    @scope = 'https://www.googleapis.com/auth/calendar.events,https://www.googleapis.com/auth/calendar'
  end

  def authorize
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_API_KEY'],
      client_secret: ENV['GOOGLE_API_SECRET'],
      scope: @scope,
      additional_parameters: { 'access_type' => 'offline' }
    )
    credentials.refresh_token = @refresh_token
    credentials.fetch_access_token!
    credentials
  end
end
