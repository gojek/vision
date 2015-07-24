require "spec_helper"

describe UserMailer do
  
  describe ".notif_email(user, change_request, status)" do
  	before do
  		@user = FactoryGirl.create(:user)
  		@change_request = FactoryGirl.create(:change_request)
  		@status = FactoryGirl.create(:change_request_status)
  		FactoryGirl.create(:user, email: 'squidward@***REMOVED***', id: 2, role: 'release_manager')
  		FactoryGirl.create(:user, email: 'crab@***REMOVED***', id: 3, role: 'approver')
  		@recipients = [@user.email, 'squidward@***REMOVED***', 'crab@***REMOVED***']
  	end

  	it "has appropriate subject" do
      mail = UserMailer.notif_email(@user, @change_request, @status)
      expect(mail.subject).to eq "Change Request Status Changed"
    end

    it "sent to all approvers" do
      mail = UserMailer.notif_email(@user, @change_request, @status)
      expect(mail.to).to eq @recipients
    end
  end
end
