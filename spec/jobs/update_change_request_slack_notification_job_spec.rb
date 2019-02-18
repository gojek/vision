require 'spec_helper'
require 'sucker_punch/testing/inline'

RSpec.describe UpdateChangeRequestSlackNotificationJob, type: :job do
  let(:change_request) {FactoryGirl.create(:change_request) }
  describe "perform async" do
    it "send notification to slack immediately" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UpdateChangeRequestSlackNotificationJob.perform_later(change_request)
      }.to have_enqueued_job.with(change_request)
    end
  end
end
