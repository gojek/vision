require 'spec_helper'
require 'sucker_punch/testing/inline'

RSpec.describe NewChangeRequestSlackNotificationJob, type: :job do
  let(:change_request) {FactoryGirl.create(:change_request) }
  let(:slack_notif) {SlackNotif.new}
  describe "perform async" do
    it "send notification to slack immediately" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        NewChangeRequestSlackNotificationJob.perform_later(change_request)
      }.to have_enqueued_job.with(change_request)
    end

    it "send notification to slack immediately" do
      ActiveJob::Base.queue_adapter = :test
      expect(slack_notif).to receive(:notify_new_cr)
      NewChangeRequestSlackNotificationJob.perform_later(change_request)
    end
  end
end
