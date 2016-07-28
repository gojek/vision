Given(/^another user has made a change request$/) do
  @other_user = FactoryGirl.create(:user)
  @cr = FactoryGirl.create(:change_request, user: @other_user)
end

When(/^I visit the change request index page$/) do
  visit change_requests_path
end

Then(/^I should be able to see that change request$/) do
  page.should have_content(@cr.id)
  page.should have_selector(:xpath, "//a[@id='show']")
  page.should_not have_selector(:xpath, "//a[@id='edit']")
  page.should_not have_selector(:xpath, "//a[@id='delete']")
end
