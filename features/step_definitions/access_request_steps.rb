Given /^an access request with employee name "([^"]*)"$/ do |employee_name|
  user = FactoryBot.create(:user)
  @ar = FactoryBot.create(:access_request, user: user, employee_name: employee_name)
  version = @ar.versions.first
  version.whodunnit = user.id
  version.save!
end

Given /^there are (\d+) access request$/ do |number|
  number = number.to_f
  user = FactoryBot.create(:user)
  for i in 0..number
    ar = FactoryBot.create(:access_request, user: user, employee_name: "Patrick Squarepants")
  end
end

Given /^I made an access request with employee name "([^"]*)"$/ do |employee_name|
  @ar = FactoryBot.create(:access_request, user: @current_user, employee_name: employee_name)
  version = @ar.versions.first
  version.whodunnit = @current_user.id
  version.save!
end

Given /^I add approver on the access request with approver name "([^"]*)"$/ do |approver_name|
  approver = FactoryBot.create(:user, name: approver_name)
  AccessRequestApproval.create(user: approver, access_request: @ar, approved: nil, notes: nil)
end

Given(/^an access request with employee name "([^"]*)" that needs my approval$/) do |employee_name|
  user = FactoryBot.create(:user)
  ar = FactoryBot.create(:access_request, user: user, employee_name: employee_name, aasm_state: "submitted")
  version = ar.versions.first
  version.whodunnit = user.id
  version.save!
  approval = AccessRequestApproval.create(user: @current_user, access_request: ar, approved: nil, notes: nil)
end

Given(/^that access request had metabase access checked as "([^"]*)"$/) do |metabase|
  @ar.metabase = metabase.to_s == "true"
end

Given(/^that access request has approved comment "([^"]*)"$/) do |comment|
  approver = FactoryBot.create(:approver_ar)
  approval = AccessRequestApproval.create(user: approver, access_request: @ar, approved: true, notes: comment)
end

Given(/^that access request has been approved on "([^"]*)"$/) do |time_approved|
  approver = FactoryBot.create(:approver_ar)
  approval = AccessRequestApproval.create(user: approver, access_request: @ar, approved: true, notes: "Ok", updated_at: time_approved)
end

Given /^an access request with employee name "([^"]*)" with "([^"]*)" as business justification$/ do |employee_name, business_justification|
  user = FactoryBot.create(:user)
  @ar = FactoryBot.create(:access_request, user: user, employee_name: employee_name, business_justification: business_justification)
  version = @ar.versions.first
  version.whodunnit = user.id
  version.save!
end