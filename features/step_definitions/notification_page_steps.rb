Given(/^I have any change request notifications$/) do
  @cr = FactoryGirl.create(:change_request, user: @current_user)
  @notifcr = FactoryGirl.create(:notification, user: @current_user, change_request: @cr, read: false, message: 'new_cr')
  visit root_path
  page.should have_content("Dashboard")
  page.should have_selector(:xpath, "//span[@id='notif-cr']")
end

When(/^I click the change request notifications button$/) do
  page.find_link('notif-cr-button').click
end

Then(/^I should be redirected to the notification page$/) do
  page.should have_content("Notifications")
end

Then(/^I could see the change request notifications$/) do
  page.should have_content("New")
  page.should have_selector(:xpath, "//span[@class='label label-success']")
  page.should have_selector(:xpath, "//li[@class='active']")
  page.should have_selector(:xpath, "//div[@id='change_request' and @class='tab-pane fade in active']")
  page.should have_content(@notifcr.change_request.id)
  page.should have_content(@notifcr.change_request.change_summary)
  page.should have_content(@notifcr.change_request.user.name)
end

Given(/^I have any incident report notifications$/) do
  @ir = FactoryGirl.create(:incident_report, user: @current_user)
  @notifir = FactoryGirl.create(:notification, user: @current_user, incident_report: @ir, read: false, message: 'new_ir')
  visit root_path
  page.should have_content("Dashboard")
  page.should have_selector(:xpath, "//span[@id='notif-ir']")
end

When(/^I click the incident report notifications button$/) do
  page.find_link('notif-ir-button').click
end

Then(/^I could see the incident report notifications$/) do
  page.should have_content("New")
  page.should have_selector(:xpath, "//span[@class='label label-success']")
  page.should have_selector(:xpath, "//li[@class='active']")
  page.should have_selector(:xpath, "//div[@id='incident_report' and @class='tab-pane fade in active']")
  page.should have_content(@notifir.incident_report.id)
  page.should have_content(@notifir.incident_report.service_impact)
  page.should have_content(@notifir.incident_report.user.name)
end

Given(/^I have no change request notifications$/) do
  visit root_path
  page.should_not have_selector(:xpath, "//span[@id='notif-cr']")
end

Then(/^I should see Nothing to display here! text$/) do
  page.should have_content("Nothing to display here!")
end

Given(/^I have no incident report notifications$/) do
  visit root_path
  page.should_not have_selector(:xpath, "//span[@id='notif-ir']")
end
