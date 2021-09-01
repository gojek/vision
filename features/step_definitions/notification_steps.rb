Given(/^I have "([^"]*)" change request notifications$/) do |change_summary|
  user = FactoryBot.create(:user)
  cr = FactoryBot.create(:change_request, change_summary: change_summary, user: user)
  notif = FactoryBot.create(:notification, user: @current_user, change_request: cr, message: 'new_cr')
  visit root_path
  page.should have_selector(:xpath, "//span[@id='notif-cr']")
end

Given(/^I have "([^"]*)" incident report notifications$/) do |service_impact|
  user = FactoryBot.create(:user)
  ir = FactoryBot.create(:incident_report, service_impact: service_impact, user: user)
  notif = FactoryBot.create(:notification, user: @current_user, incident_report: ir, message: 'new_ir')
  visit root_path
  page.should have_selector(:xpath, "//span[@id='notif-ir']")
end
