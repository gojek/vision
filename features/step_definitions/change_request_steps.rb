Given /^a change request with summary "(.*?)"$/ do |change_summary|
  user = FactoryGirl.create(:user)
  @cr = FactoryGirl.create(:change_request, user: user, change_summary: change_summary)
end

Given(/^I have created a change request with summary "([^"]*)"$/) do |change_summary|
  @cr = FactoryGirl.create(:change_request, user: @current_user, change_summary: change_summary)
  version = @cr.versions.first
  version.update(whodunnit: @current_user.id)
end

Given(/^there is a "([^"]*)" change request with summary "([^"]*)"$/) do |state, change_summary|
  cr_state = Hash["submitted", :submitted_change_request, "scheduled", :scheduled_change_request, "rejected", :rejected_change_request, "deployed", :deployed_change_request, "rollbacked", :rollbacked_change_request, "cancelled", :cancelled_change_request, "closed", :closed_change_request ]
  user = FactoryGirl.create(:user)
  @cr = FactoryGirl.create(cr_state[state], user: user, change_summary: change_summary)
  version = @cr.versions.first
  version.update(whodunnit: @current_user.id)
end

Given(/^a hotfix has been made for that rollbacked change request with summary "([^"]*)"$/) do |change_summary|
  user = FactoryGirl.create(:user)
  hotfix_cr = FactoryGirl.create(:change_request, user: user, reference_cr_id: @cr.id, change_summary: change_summary)
end
