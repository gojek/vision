When(/^I try to access create hotfix method directly$/) do
  visit create_hotfix_path(@cr.id)
end

Then(/^it should be restricted and I am redirected to the change request index$/) do
  current_path.should == '/change_requests'
end

Given(/^there is a rollbacked CR$/) do
  @cr = FactoryGirl.create(:rollbacked_change_request, user: @current_user)
  @version = @cr.versions.first
  @version.update(whodunnit: @current_user.id)
end

When(/^I visit the rollbacked CR$/) do
  visit change_requests_path
  page.find_link('Show').click
  page.should have_content(@cr.id)
  page.should have_content('rollbacked')
end

When(/^clicked create hotfix button$/) do
  page.find_link('Create Hotfix').click
end

Then(/^I will be redirected to a change request new page$/) do
  page.should have_content('Request')
  page.should have_content('Analysis Impact Solution')
  page.should have_content('Design and Backup Plan')
  page.should have_content('Testing')
  page.should have_content('Implementation')
end

Then(/^the rollbacked CR will be referenced$/) do
  page.should have_content("Reference to Change Request ##{@cr.id}")
end
