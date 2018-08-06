Given /^an access request with employee name "([^"]*)" with "([^"]*)" as business justification$/ do |employee_name, business_justification|
  user = FactoryGirl.create(:user)
  ar = FactoryGirl.create(:access_request, user: user, employee_name: employee_name, business_justification: business_justification)
  version = ar.versions.first
  version.whodunnit = user.id
  version.save!
end
