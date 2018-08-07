Then /^I should see access requests with employee name "(.*?)"$/ do |employee_name|
  save_and_open_page
  page.should have_content(employee_name)
end
