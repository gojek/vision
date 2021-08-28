require 'rails_helper'
require 'sucker_punch/testing/inline'
require 'webmock/rspec'


RSpec.describe IncidentReportNewSlackNotifJob, type: :job do
  let(:incident_report) {FactoryGirl.create(:incident_report) }
  describe "perform async" do
    it "send notification to slack immediately" do
      stub = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .to_return(status: 200, body: '{"ok": true}', headers: {})
      ActiveJob::Base.queue_adapter = :test
      IncidentReportNewSlackNotifJob.perform_async(incident_report)
      expect(stub).to have_been_requested
    end
  end
end
