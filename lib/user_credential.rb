# frozen_string_literal: true

require 'googleauth'

class UserCredential
  def initialize(user)
    @user = user
    @scope = 'https://www.googleapis.com/auth/calendar.events,https://www.googleapis.com/auth/calendar'
  end

  def authorize
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_API_KEY'],
      client_secret: ENV['GOOGLE_API_SECRET'],
      scope: @scope,
      additional_parameters: { 'access_type' => 'offline' }
    )
    credentials.refresh_token = @user.refresh_token
    if @user.expired?
      credentials.fetch_access_token!
    else
      credentials.access_token = @user.token
    end
    credentials
  end
end
