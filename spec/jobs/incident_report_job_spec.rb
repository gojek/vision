require 'rails_helper'
require 'sucker_punch/testing/inline'

describe IncidentReportJob, :type => :job do
  let(:user) {FactoryBot.create(:user)}
  let(:irs) {FactoryBot.create_list(:incident_report, 10, user: user)}

  describe "#perform" do
    it "delivers an email to a vaild sender with valid attributes" do
      ActiveJob::Base.queue_adapter = :test
      irs.map! {|ir| ir.id }
      expect{
        IncidentReportJob.perform_async(irs, user.email)
      }.to have_enqueued_job(ActionMailer::DeliveryJob)
    end 
  end 
end
