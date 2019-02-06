require 'spec_helper'
require 'google_oauth.rb'

describe GoogleOAuth do
  let(:user) { FactoryGirl.create(:user)}

  describe "When user requested new access_token with refresh token" do

    before :each do
       # Refresh token stub 
      stub_request(:post, 'https://accounts.google.com/o/oauth2/token')
        .with(body: { 'refresh_token' => '123456',
          'client_id' => ENV['GOOGLE_API_KEY'],
          'client_secret' => ENV['GOOGLE_API_SECRET'],
          'grant_type' => 'refresh_token'})
        .to_return(status: 200, body: '{
          "access_token" : "45678",
          "expired_in" : 3600
        }')
    end

    it "Should update user token access" do
      current_token = user.token
      GoogleOAuth.refresh_token(user)
      user.reload
      expect(user.token).not_to eq(current_token)
      expect(user.token).to eq("45678")
    end

  end
end
