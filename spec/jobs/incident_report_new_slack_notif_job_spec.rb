require 'spec_helper'
require 'sucker_punch/testing/inline'

RSpec.describe IncidentReportNewSlackNotifJob, type: :job do
  let(:incident_report) {FactoryGirl.create(:incident_report) }
  describe "perform async" do
    it "send notification to slack immediately" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        IncidentReportNewSlackNotifJob.perform_later(incident_report)
      }.to have_enqueued_job.with(incident_report)
    end
  end
end
