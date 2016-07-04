Given(/^someone has made a change request$/) do

  with_versioning do
    expect(PaperTrail.should be_enabled).to eq true
    @user = FactoryGirl.create(:user)
    @cr = FactoryGirl.create(:change_request, user: @user)
    @version = @cr.versions.first
    @version.update(whodunnit: @user.id)
  end
end

Given(/^I am in that change request's show page$/) do
  visit("/change_requests/#{@cr.id}")
end

When(/^I input @ in the comment field$/) do
  fill_in("comment", with: "@")
end

When /^wait$/ do
  sleep 2
end

Then(/^it should show suggestions that shows all users name$/) do
  page.should have_selector(:xpath, "//div[@class='atwho-view' and @style]")
end
