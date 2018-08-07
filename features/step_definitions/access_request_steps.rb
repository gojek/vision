Given /^an access request with employee name "([^"]*)"$/ do |employee_name|
  user = FactoryGirl.create(:user)
  ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name)
  version = ar.versions.first
  version.whodunnit = user.id
  version.save!
end
