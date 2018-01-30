require 'spec_helper'
require 'sucker_punch/testing/inline'

describe IncidentReportJob, :type => :job do
  let(:user) {FactoryGirl.create(:user)}
  let(:irs) {FactoryGirl.create_list(:incident_report, 10, user: user)}

  describe "#perform" do
    it "delivers an email to a vaild sender with valid attributes" do
      ActiveJob::Base.queue_adapter = :test
      irs.map! {|ir| ir.id }
      IncidentReportJob.perform_async(irs, user.email)
      expect(ActionMailer::Base.deliveries.size).to eq 1
      email = ActionMailer::Base.deliveries.first
      expect(email.subject).to eq "Incident Report CSV"
      expect(email.to[0]).to eq user.email
    end 
  end 
end
