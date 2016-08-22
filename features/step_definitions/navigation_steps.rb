Given /^I am in page "(.*?)"$/ do |page|
  visit page
end

When /^I visit page "(.*?)"$/ do |page|
  visit page
end

When /^I press button "(.*?)"$/ do |button|
  click_button(button)
end

When /^I press link "(.*?)"$/ do |link|
  click_link(link)
end

When /^I input "(.*?)" in field "(.*?)"$/ do |value, field_name|
  fill_in(field_name, with: value)
end

Then /^I am in homepage$/ do
  pending
end

Then(/^I should be redirected to a new change request page$/) do
  page.should have_content("Request")
  page.should have_content("Analysis Impact Solution")
  page.should have_content("Design and Backup Plan")
  page.should have_content("Testing")
  page.should have_content("Implementation")
end
