require "spec_helper"

RSpec.describe "User can save change request as a draf", :type=>:feature do
  it "User save to draft" do
    user = FactoryGirl.create(:user)
    change_request = FactoryGirl.create(:change_request, user: user)
    login_as(user)
  	
    visit new_change_request_path
    visit edit_change_request_path(change_request)

    expect(page).to have_text("Change Request") 

    fill_in "change_request_change_summary", :with => "Ini Masih Draft"
    click_button "save"

    expect(page).to have_text("Change request was created as a draft.")
  end
end