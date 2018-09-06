Then(/^I should be able to see "([^"]*)"$/) do |string|
  page.should have_content(string)
end

Then(/^the page should have "([^"]*)" on some tag$/) do |string|
  expect(page).to have_xpath("//a[contains(., string)]")
end

Then(/^I should not be able to see "([^"]*)"$/) do |string|
  page.should_not have_content(string)
end

Then(/^the page should have "([^"]*)" link$/) do |selector|
  page.should have_link(selector)
end

Then(/^the page should not have "([^"]*)" link$/) do |selector|
  page.should_not have_link(selector)
end

Then(/^the "([^"]*)" field should be filled in with "([^"]*)"$/) do |field, string|
  field_name = field.downcase.split(" ").join("_")
  page.should have_field("change_request_#{field_name}", with: string)
end

Then(/^the "([^"]*)" field should be empty$/) do |field|
  field_name = field.downcase.split(" ").join("_")
  page.should have_field("change_request_#{field_name}", with: nil)
end

Then(/^the page should have checked input "([^"]*)"$/) do |id|
	page.find_by_id(id)[:checked] == 'checked'
end