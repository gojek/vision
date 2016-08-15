Then(/^all notifications should be removed$/) do
  page.should_not have_selector(:xpath, "//span[@id='notif-cr']")
  page.should_not have_selector(:xpath, "//span[@id='notif-ir']")
end
