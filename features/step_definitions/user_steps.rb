Given /^I am logged in$/ do
  @current_user = FactoryGirl.create(:user)
  login_as @current_user
end

Given /^a user named "(.*?)"$/ do |name|
  FactoryGirl.create(:user, name: name)
end

Given /^I am logged in as "(.*?)"$/ do |name|
  login_as User.find_by(name: name)
end

Given /^I am logged in as approver$/ do
  @current_user = FactoryGirl.create(:approver)
  login_as @current_user
end
