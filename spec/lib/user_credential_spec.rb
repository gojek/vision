require 'rails_helper'
require 'user_credential.rb'
require 'googleauth'
require 'webmock/rspec'
require 'json'
require 'helpers.rb'

RSpec.configure do |c|
  c.include Helpers
end

describe UserCredential do

  let(:expired_user) {FactoryBot.create(:user, expired_at: Time.now - 1.minutes)}
  let(:non_expired_user) {FactoryBot.create(:user, expired_at: Time.now + 4.minutes)}

  before :each do
    # WebMock.allow_net_connect!
    # WebMock.after_request do |request_signature, response|
    #   puts "Request #{request_signature} was made and #{response.body} was returned"
    # end    
    auth_stub
  end

  describe "when authorize with spesified refresh_token" do
    it "return authorization object with access_token" do
      user_credential = UserCredential.new expired_user
      authorization_object = user_credential.authorize
      expect(authorization_object.access_token).to eq("token-1234")
    end

    it "no call request for update token if not yet expired" do
      user_credential = UserCredential.new non_expired_user
      authorization_object = user_credential.authorize
      expect(auth_stub).not_to have_been_requested
    end
  end


  
end
