Then(/^it should show suggestions that shows all users name$/) do
  page.should have_selector(:xpath, "//div[@class='atwho-view' and @style]")
end
