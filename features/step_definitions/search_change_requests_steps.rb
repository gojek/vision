When /^I search "(.*?)" in search box$/ do |keywords|
  fill_in('search-box', with: keywords)
  click_button('search-button')
end

Then /^I should see change requests with summary "(.*?)"$/ do |change_summary|
  save_and_open_page
  page.should have_content(change_summary)
end
