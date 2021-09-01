When /^I add "([^"]*)" on "([^"]*)" comment section$/ do |ar_comment, employee_name|
  access_request_id = AccessRequest.find_by_employee_name(employee_name).id
  ar = FactoryBot.create(:access_request_comment, user_id: @current_user.id, access_request_id: access_request_id, body: ar_comment)
  ar.save!
end