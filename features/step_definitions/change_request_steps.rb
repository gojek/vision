Given /^a change request with summary "(.*?)"$/ do |change_summary|
  user = FactoryGirl.create(:user)
  cr = FactoryGirl.create(:change_request, user: user, change_summary: change_summary)
end
