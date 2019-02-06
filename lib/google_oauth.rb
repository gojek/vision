require 'net/http'
require 'json'

class GoogleOAuth

  def self.refresh_token(user)
    response = request_token_from_google(user.refresh_token)
    data = JSON.parse(response.body)
    Rails.logger.info("Got This from Response: #{data.inspect}" )
    user.update_attributes(
      token: data['access_token'],
      expired_at: Time.now + (data['expires_in'].to_i).seconds
    )
  end

  def self.token_to_params(refresh_token)
    { 'refresh_token' => refresh_token,
    'client_id' => ENV['GOOGLE_API_KEY'],
    'client_secret' => ENV['GOOGLE_API_SECRET'],
    'grant_type' => 'refresh_token'}
  end

  def self.request_token_from_google(refresh_token)
    url = URI('https://accounts.google.com/o/oauth2/token')
    Net::HTTP.post_form(url, token_to_params(refresh_token))
  end

end
