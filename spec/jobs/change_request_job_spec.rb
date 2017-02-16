require 'spec_helper'

describe ChangeRequestJob, :type => :job do
  let(:user) {FactoryGirl.create(:user, )}
  let(:crs) {ChangeRequest.all}

  describe "#perform" do
    it "enqueue a job" do 
      ActiveJob::Base.queue_adapter = :test
      ChangeRequestJob.perform_in(120,crs.ids, user.email)
      expect(SuckerPunch::Queue.all.size).to eq 1
    end 

    it "delivers an email" do
      ChangeRequestJob.perform_async(crs.ids, user.email)
      expect(ActionMailer::Base.deliveries.size).to be >= 1
    end 
  end 
end
