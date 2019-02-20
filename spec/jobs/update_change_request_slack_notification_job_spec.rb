require 'spec_helper'
require 'sucker_punch/testing/inline'

RSpec.describe UpdateChangeRequestSlackNotificationJob, type: :job do
  let(:change_request) {FactoryGirl.create(:change_request) }
  describe "perform async" do
    it "enqueued send notification to slack" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UpdateChangeRequestSlackNotificationJob.perform_later(change_request)
      }.to have_enqueued_job.with(change_request)
    end

    it "request stub for notification to slack" do
      stub = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .to_return(status: 200, body: '{"ok": true}', headers: {})
      ActiveJob::Base.queue_adapter = :test
      UpdateChangeRequestSlackNotificationJob.perform_async(change_request)
      expect(stub).to have_been_requested.times(6)
    end
  end
end
