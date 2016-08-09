Then(/^I should be redirected to the notification page$/) do
  page.should have_content("Notifications")
end

Given(/^I have no change request notifications$/) do
  visit root_path
  page.should_not have_selector(:xpath, "//span[@id='notif-cr']")
end

Then(/^I should see Nothing to display here! text$/) do
  page.should have_content("Nothing to display here!")
end

Given(/^I have no incident report notifications$/) do
  visit root_path
  page.should_not have_selector(:xpath, "//span[@id='notif-ir']")
end

Then(/^the "([^"]*)" section should be active$/) do |section|
  selector = section.downcase.split(" ").join("_")
  li_id = selector + "_pill"
  page.should have_selector(:xpath, "//li[@id='#{li_id}' and @class='active']")
  page.should have_selector(:xpath, "//div[@id='#{selector}' and @class='tab-pane fade in active']")
end

Then(/^the "([^"]*)" tab should be active$/) do |tab|
  page.should have_content(tab)
  page.should have_selector(:xpath, "//a[@href='##{tab}']")
  page.should have_selector(:xpath, "//div[@id='#{tab}' and @class='tab-pane fade in col-sm-12']")
end
