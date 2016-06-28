require 'spec_helper.rb'

describe NotificationsController do
  let(:user) {FactoryGirl.create(:user)}
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    request.env["HTTP_REFERER"] = "vt-vision.com"

  end
  describe "GET #clear_notifications" do

    it 'should clear all notifications of the user' do
      cr = FactoryGirl.create(:change_request)
      notification = FactoryGirl.create(:notification, user: user, change_request: cr)
      get :clear_notifications
      notification.reload
      expect(notification.read).to eq true

    end

    it 'should redirect to request.referer' do
      get :clear_notifications
      response.should redirect_to "vt-vision.com"
    end
  end
end
