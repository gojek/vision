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

Given(/^an access request with employee name "([^"]*)" that has been approved with comment "([^"]*)" and "([^"]*)"$/) do |employee_name, comment, comment2|
  user = FactoryGirl.create(:user)
  approver = FactoryGirl.create(:approver_ar)
  approver2 = FactoryGirl.create(:approver_ar)
  ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name, aasm_state: "submitted")
  version = ar.versions.first
  version.whodunnit = user.id
  version.save!
  approval = AccessRequestApproval.create(user: approver, access_request: ar, approved: true, notes: comment)
  approval2 = AccessRequestApproval.create(user: approver2, access_request: ar, approved: true, notes: comment2)
end

Given(/^an access request with employee name "([^"]*)" that has been approved on "([^"]*)" and "([^"]*)"$/) do |employee_name, date1, date2|
  user = FactoryGirl.create(:user)
  approver = FactoryGirl.create(:approver_ar)
  approver2 = FactoryGirl.create(:approver_ar)
  ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name, aasm_state: "submitted")
  version = ar.versions.first
  version.whodunnit = user.id
  version.save!
  approval = AccessRequestApproval.create(user: approver, access_request: ar, approved: true, notes: "Cool", updated_at: date1)
  approval2 = AccessRequestApproval.create(user: approver2, access_request: ar, approved: true, notes: "Mantap", updated_at: date2)
end