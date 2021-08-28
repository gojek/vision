require 'rails_helper'
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

  describe "case when event is created by google calendar API" do
    it "returned event object with is_success equals true" do
      save_event_success_stub
      event = Event.build_event_from_change_request(change_request)
      google_event = google_client.upsert_event(event)
      expect(google_event.success?).to eq true
    end
  end
end
