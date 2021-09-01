require "spec_helper"

describe UserMailer do

  describe ".notif_email(user, change_request, status)" do
  	before do
  		@user = FactoryBot.create(:user)
  		@change_request = FactoryBot.create(:change_request)
  		@status = FactoryBot.create(:change_request_status)
  		@recipients = [@user.email]
      @approvals = @change_request.approvals
      @approvals.each do |approval|
        @recipients << approval.user.email
      end
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
