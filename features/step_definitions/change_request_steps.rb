Given /^a change request with summary "(.*?)"$/ do |change_summary|
  user = FactoryBot.create(:user)
  @cr = FactoryBot.create(:change_request, user: user, change_summary: change_summary)
end

Given(/^I have created a change request with summary "([^"]*)"$/) do |change_summary|
  @cr = FactoryBot.create(:change_request, user: @current_user, change_summary: change_summary)
  version = @cr.versions.first
  version.update(whodunnit: @current_user.id)
end

Given(/^there is a "([^"]*)" change request with summary "([^"]*)"$/) do |state, change_summary|
  cr_state = Hash["submitted", :submitted_change_request, "scheduled", :scheduled_change_request, "rejected", :rejected_change_request, "deployed", :deployed_change_request, "rollbacked", :rollbacked_change_request, "cancelled", :cancelled_change_request, "closed", :closed_change_request ]
  user = FactoryBot.create(:user)
  @cr = FactoryBot.create(cr_state[state], user: user, change_summary: change_summary)
  version = @cr.versions.first
  version.update(whodunnit: @current_user.id)
end

Given(/^a hotfix has been made for that rollbacked change request with summary "([^"]*)"$/) do |change_summary|
  user = FactoryBot.create(:user)
  hotfix_cr = FactoryBot.create(:change_request, user: user, reference_cr_id: @cr.id, change_summary: change_summary)
end

Given(/^a change request with summary "([^"]*)" that needs my approval$/) do |change_summary|
  user = FactoryBot.create(:user)
  cr = FactoryBot.create(:change_request, user: user, change_summary: change_summary)
  approval = Approval.create(user: @current_user, change_request: cr, approve: nil)
end

Given(/^I created a change request with summary "([^"]*)"$/) do |change_summary|
  cr = FactoryBot.create(:change_request, user: @current_user, change_summary: change_summary)
end

Given(/^I am a "([^"]*)" in a change request with summary "([^"]*)"$/) do |role, change_summary|
  user = FactoryBot.create(:user)
  cr = FactoryBot.create(:change_request, user: user, change_summary: change_summary)
  case role
    when "collaborator"
      cr.update(collaborators: cr.collaborators << @current_user)
    when "implementer"
      cr.update(implementers: cr.implementers << @current_user)
    when "tester"
      cr.update(testers: cr.testers << @current_user)
    when "approver"
      approval = Approval.create(user: @current_user, change_request: cr, approve: nil)
  end
  cr.update(associated_user_ids: cr.associated_user_ids << @current_user.id)
end

Given(/^a change request with summary "([^"]*)" that I approved$/) do |change_summary|
  user = FactoryBot.create(:user)
  cr = FactoryBot.create(:change_request, user: user, change_summary: change_summary)
  cr.approvals.delete_all
  Approval.create(user: @current_user, change_request: cr, approve: true)
  @current_user.update(associated_change_requests: @current_user.associated_change_requests << cr)
end

Given(/^I am a "([^"]*)" in a change request with summary "([^"]*)" that has been approved$/) do |role, change_summary|
  user = FactoryBot.create(:user)
  cr = FactoryBot.create(:change_request, user: user, change_summary: change_summary)
  case role
    when "collaborator"
      cr.update(collaborators: cr.collaborators << @current_user)
    when "implementer"
      cr.update(implementers: cr.implementers << @current_user)
    when "tester"
      cr.update(testers: cr.testers << @current_user)
    when "approver"
      approval = Approval.create(user: @current_user, change_request: cr, approve: nil)
  end
  cr.update(associated_user_ids: cr.associated_user_ids << @current_user.id)
  cr.approvals.update_all(approve: true)
end
