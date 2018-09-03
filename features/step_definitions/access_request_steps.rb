Given /^an access request with employee name "([^"]*)"$/ do |employee_name|
  user = FactoryGirl.create(:user)
  ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name)
  version = ar.versions.first
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

Given(/^an access request approved comment "([^"]*)" with employee name "([^"]*)"$/) do |comment, employee_name|
  ar = AccessRequest.where(:employee_name => employee_name).first
  approver = FactoryGirl.create(:approver_ar)
  approval = AccessRequestApproval.create(user: approver, access_request: ar, approved: true, notes: comment)
end

Given(/^an access request approval on "([^"]*)" with employee name "([^"]*)"$/) do |time_approved, employee_name|
  ar = AccessRequest.where(:employee_name => employee_name).first
  approver = FactoryGirl.create(:approver_ar)
  approval = AccessRequestApproval.create(user: approver, access_request: ar, approved: true, notes: "Ok", updated_at: time_approved)
end