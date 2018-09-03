Given /^an access request with employee name "([^"]*)"$/ do |employee_name|
  user = FactoryGirl.create(:user)
  @ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name)
  version = @ar.versions.first
  version.whodunnit = user.id
  version.save!
end

Given(/^an access request with employee name "([^"]*)" that needs my approval$/) do |employee_name|
  user = FactoryGirl.create(:user)
  ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name, aasm_state: "submitted")
  version = ar.versions.first
  version.whodunnit = user.id
  version.save!
  approval = AccessRequestApproval.create(user: @current_user, access_request: ar, approved: nil, notes: nil)
end

Given(/^that access request has approved comment "([^"]*)"$/) do |comment|
  approver = FactoryGirl.create(:approver_ar)
  approval = AccessRequestApproval.create(user: approver, access_request: @ar, approved: true, notes: comment)
end

Given(/^that access request has been approved on "([^"]*)"$/) do |time_approved|
  approver = FactoryGirl.create(:approver_ar)
  approval = AccessRequestApproval.create(user: approver, access_request: @ar, approved: true, notes: "Ok", updated_at: time_approved)
end
Given /^an access request with employee name "([^"]*)" with "([^"]*)" as business justification$/ do |employee_name, business_justification|
  user = FactoryGirl.create(:user)
  @ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name, business_justification: business_justification)
  version = @ar.versions.first
  version.whodunnit = user.id
  version.save!
end