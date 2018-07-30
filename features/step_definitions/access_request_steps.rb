Given /^an access request with employee name "(.*?)"$/ do |employee_name|
  user = FactoryGirl.create(:user)
  @cr = FactoryGirl.create(:access_request, user: user, employee_name: employee_name)
end

Given(/^an access request with employee name "([^"]*)" that needs my approval$/) do |employee_name|
  user = FactoryGirl.create(:user)
  ar = FactoryGirl.create(:access_request, user: user, change_summary: employee_name)
  approval = AccessRequestApproval.create(user: @current_user, access_request: ar, approved: nil)
end

