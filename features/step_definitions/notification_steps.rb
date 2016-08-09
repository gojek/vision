Given(/^I have "([^"]*)" change request notifications$/) do |change_summary|
  user = FactoryGirl.create(:user)
  cr = FactoryGirl.create(:change_request, change_summary: change_summary, user: user)
  notif = FactoryGirl.create(:notification, user: @current_user, change_request: cr, message: 'new_cr')
  visit root_path
  page.should have_selector(:xpath, "//span[@id='notif-cr']")
end

Given(/^I have "([^"]*)" incident report notifications$/) do |service_impact|
  user = FactoryGirl.create(:user)
  ir = FactoryGirl.create(:incident_report, service_impact: service_impact, user: user)
  notif = FactoryGirl.create(:notification, user: @current_user, incident_report: ir, message: 'new_ir')
  visit root_path
  page.should have_selector(:xpath, "//span[@id='notif-ir']")
end
