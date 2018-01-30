require 'spec_helper'
require 'sucker_punch/testing/inline'

describe ChangeRequestJob, :type => :job do
  let(:user) {FactoryGirl.create(:user)}
  let(:crs) {FactoryGirl.create_list(:change_request, 10, user: user)}

  describe "#perform" do
    it "delivers an email to a vaild sender with valid attributes" do
      ActiveJob::Base.queue_adapter = :test
      crs.map! {|c| c.id }
      ChangeRequestJob.perform_async(crs, user.email)
      expect(ActionMailer::Base.deliveries.size).to eq 1
      email = ActionMailer::Base.deliveries.first
      expect(email.subject).to eq "Change Requests CSV"
      expect(email.to[0]).to eq user.email
    end 
  end 
end
