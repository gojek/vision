require 'spec_helper'
require 'google_client'
require 'webmock/rspec'
require 'json'
require 'helpers.rb'
require 'event.rb'

RSpec.configure do |c|
  c.include Helpers
end

describe GoogleClient do
  let(:user) { FactoryGirl.create(:user) }
  let(:google_client) { GoogleClient.new user}
  let(:change_request) { FactoryGirl.create(:change_request, user: user) }

  before :each do
    # WebMock.allow_net_connect!
    # WebMock.after_request do |request_signature, response|
    #   puts "Request #{request_signature} was made and #{response.inspect} was returned"
    # end    
  end

  describe "case when event is created by google calendar API" do
    it "returned event object with is_success equals true" do
      save_event_success_stub
      event = Event.build_event_from_change_request(change_request)
      event = google_client.upsert_event(event)
      expect(event.success?).to eq true
    end
  end

  describe "case when google calendar API return client error" do
    it "returned event object with is_success equals false" do
      save_event_error_stub
      event = Event.build_event_from_change_request(change_request)
      event = google_client.upsert_event(event)
      expect(event.success?).to eq false
    end

    it "returned event object with error message" do
      save_event_error_stub
      event = Event.build_event_from_change_request(change_request)
      event = google_client.upsert_event(event)
      expect(event.error_messages).to eq "error" 
    end
  end
end
