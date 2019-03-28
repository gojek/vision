require 'spec_helper'
require 'sucker_punch/testing/inline'

describe ChangeRequestJob, :type => :job do
  let(:user) {FactoryGirl.create(:user)}
  let(:crs) {FactoryGirl.create_list(:change_request, 10, user: user)}

  describe "#perform" do
    it "delivers an email to a vaild sender with valid attributes" do
      ActiveJob::Base.queue_adapter = :test
      crs.map! {|c| c.id }
      expect { 
        ChangeRequestJob.perform_async(crs, user.email)
      }.to have_enqueued_job(ActionMailer::DeliveryJob)
    end 
  end 
end
