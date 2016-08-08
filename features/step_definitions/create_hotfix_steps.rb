Then(/^the rollbacked change request should be referenced$/) do
  page.should have_content("Reference to Change Request ##{@cr.id}")
end
