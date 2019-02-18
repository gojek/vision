require "googleauth"

class UserCredential
  def initialize(refresh_token, scope)
    @refresh_token = refresh_token
    @scope = scope
  end

  def get_credentials
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_API_KEY'],
      client_secret: ENV['GOOGLE_API_SECRET'],
      scope: @scope,
      additional_parameters: { "access_type" => "offline" })
    credentials.refresh_token = @refresh_token
    credentials.fetch_access_token!
    return credentials
  end
end
