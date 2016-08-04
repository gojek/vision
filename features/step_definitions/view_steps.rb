Then(/^I should be able to see "([^"]*)"$/) do |string|
  page.should have_content(string)
end

Then(/^I should not be able to see "([^"]*)"$/) do |string|
  page.should have_content(string)
end

Then(/^the page should have selector "([^"]*)"$/) do |selector|
  page.should have_selector(:xpath, selector)
end

Then(/^the page should not have selector "([^"]*)"$/) do |selector|
  page.should_not have_selector(:xpath, selector)
end
