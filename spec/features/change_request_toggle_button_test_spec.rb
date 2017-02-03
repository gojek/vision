require "spec_helper"

RSpec.describe "Change Request testing Toggle Button", type: :feature do
  it "Toggle button must have the same state as the boolean in testing_environment_variable attribute of the ChangeRequest model " do
   	user = FactoryGirl.create(:user)
   	change_request = FactoryGirl.create(:change_request, user: user)
   	login_as(user)
    visit edit_change_request_path(id: change_request.id)
    expect(page).to have_xpath("//input[@id='change_request_testing_environment_available'][@checked='checked']")
  end
end
