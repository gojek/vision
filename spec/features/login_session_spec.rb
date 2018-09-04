require "spec_helper"

RSpec.describe "Login session timeout testing", :type=>:feature do
  it "User login session should be in one week" do
    user = FactoryGirl.create(:user)
    login_as(user)
    login_time = Time.current
    #forward time to 6 days later  
    Timecop.freeze(Time.current + 6.days) do
      #login_time is last time user login
      expect(user.timedout?(login_time)).to eq(false)
      visit new_change_request_path
      expect(page).to have_content("Change Request")
    end
    #forward time to 8 days later
    Timecop.freeze(Time.current + 8.days) do
      expect(user.timedout?(login_time)).to eq(true)
    end
  end
end