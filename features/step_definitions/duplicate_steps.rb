Given(/^I have created a change request$/) do
  @cr = FactoryGirl.create(:change_request, user: @current_user)
end
Given(/^I am in the change requests index page$/) do
  visit change_requests_path
  page.should have_content(@cr.id)
end

When(/^I click on the duplicate link$/) do
  page.find_link('Duplicate').click
end

Then(/^I should be redirected to a new change request page$/) do
  page.should have_content("Request")
  page.should have_content("Analysis Impact Solution")
  page.should have_content("Design and Backup Plan")
  page.should have_content("Testing")
  page.should have_content("Implementation")
end

Then(/^I should be the requestor of the CR$/) do
  expect(page).to have_field("change_request_requestor_name", with: @current_user.name)
end

Then(/^all field should be filled in except implementation and grace period dates$/) do
  expect(page).to have_field("change_request_change_summary", with: @cr.change_summary)
  page.find_link('Implementation').click
  expect(page).to have_field("change_request_planned_completion", with: nil)
  expect(page).to have_field("change_request_schedule_change_date", with: nil)
  expect(page).to have_field("change_request_grace_period_starts", with: nil)
  expect(page).to have_field("change_request_grace_period_end", with: nil)
end
