require 'rails_helper'
require 'sucker_punch/testing/inline'

RSpec.describe ApprovalChangeRequestSlackNotificationJob, type: :job do
  let(:change_request) {FactoryGirl.create(:change_request) }
  describe "perform async" do
    it "send notification to slack immediately" do
    	approval = Approval.where(change_request_id: change_request.id, user_id: change_request.approvals.first.user_id).first
    	approval.approve = true
      approval.approval_date = Time.current
      approval.notes = "accepted"
      approval.save!

      ActiveJob::Base.queue_adapter = :test
      expect {
        ApprovalChangeRequestSlackNotificationJob.perform_later(change_request, approval)
      }.to have_enqueued_job.with(change_request, approval)
    end

    it "request stub for notification to slack" do
    	approval = Approval.where(change_request_id: change_request.id, user_id: change_request.approvals.first.user_id).first
    	approval.approve = true
      approval.approval_date = Time.current
      approval.notes = "accepted"
      approval.save!

      stub = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .to_return(status: 200, body: '{"ok": true}', headers: {})
      ActiveJob::Base.queue_adapter = :test
      ApprovalChangeRequestSlackNotificationJob.perform_async(change_request, approval)
      expect(stub).to have_been_requested.times(5)
    end
  end
end

