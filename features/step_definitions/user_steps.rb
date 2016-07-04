Given /^I am logged in$/ do
  login_as FactoryGirl.create(:user)
end

Given /^a user named "(.*?)"$/ do |name|
  FactoryGirl.create(:user, name: name)
end

Given /^I am logged in as "(.*?)"$/ do |name|
  login_as User.find_by(name: name)
end

Given /^I am logged in as approver$/ do
  @approver = FactoryGirl.create(:approver)
  login_as @approver
end 
