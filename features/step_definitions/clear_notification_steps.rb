Given(/^I have any change request \/ incident report notifications$/) do
  @user = FactoryGirl.create(:user)
  @cr = FactoryGirl.create(:change_request, user: @user)
  @ir = FactoryGirl.create(:incident_report, user: @user)
  @notifcr = FactoryGirl.create(:notification, user: @approver, change_request: @cr)
  @notifir = FactoryGirl.create(:notification, user: @approver, incident_report: @ir)
  visit root_path
  page.should have_content("Dashboard")
  page.should have_selector(:xpath, "//span[@id='notif-cr']")
  page.should have_selector(:xpath, "//span[@id='notif-ir']")
end

When(/^I click the clear notification button$/) do
  page.find_link('clear-notification').click
end

Then(/^all notifications should be removed$/) do
  page.should_not have_selector(:xpath, "//span[@id='notif-cr']")
  page.should_not have_selector(:xpath, "//span[@id='notif-ir']")
end
