describe ChangeRequestJob do
  let(:job) {ChangeRequestJob.new }	
  let(:user) {FactoryGirl.create(:user, )}
  let(:crs) {ChangeRequest.all}

  describe "#perform" do
    it "delivers an email" do 
      expect{  
        job.perform(crs.ids, user.email)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end 
  end 
end
