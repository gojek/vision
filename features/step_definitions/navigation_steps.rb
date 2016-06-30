Given /^I visit page "(.*?)"$/ do |page|
  visit page
end

When /^I press button "(.*?)"$/ do |button|
  click_button(button)
end

When /^I input "(.*?)" in field "(.*?)"$/ do |value, field_name|
  pending
end

Then /^I am in homepage$/ do
  pending
end
