require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    request.env["HTTP_REFERER"] = "vt-vision.com"
  end

  describe "GET #clear_notifications" do
    it 'should clear all notifications of the user' do
      cr = FactoryBot.create(:change_request)
      notification = FactoryBot.create(:notification, user: user, change_request: cr)
      get :clear_notifications
      expect(user.notifications.cr.count).to eq 0
    end

    it 'should redirect to request.referer' do
      get :clear_notifications
      expect(response).to redirect_to("vt-vision.com")
    end
  end

  describe 'GET #index' do
    it 'should render the notification index page' do
      get :index
      expect(:response).to render_template :index
    end

    it 'should assign cr to @active' do
      get :index, params: { type: 'cr' }
      expect(assigns(:active)).to eq 'cr'
    end

    it 'should assign ir to @active' do
      get :index, params: { type: 'ir' }
      expect(assigns(:active)).to eq 'ir'
    end

    it 'should assign true to @have_cr_notif if user have any change request notification' do
      cr = FactoryBot.create(:change_request)
      notification = FactoryBot.create(:notification, user: user, change_request: cr, message: 'new_cr')
      get :index, params: { type: 'cr' }
      expect(assigns(:notifications).count).to eq 1
      expect(assigns(:have_cr_notif)).to eq true
    end

    it 'should assign false to @have_cr_notif if user have no change request notification' do
      get :index, params: { type: 'cr' }
      expect(assigns(:notifications).count).to eq 0
      expect(assigns(:have_cr_notif)).to eq false
    end

    it 'should assign true to @have_ir_notif if user have any incident report notification' do
      ir = FactoryBot.create(:incident_report)
      notification = FactoryBot.create(:notification, user: user, incident_report: ir, message: 'new_ir')
      get :index, params: { type: 'ir' }
      expect(assigns(:notifications).count).to eq 1
      expect(assigns(:have_ir_notif)).to eq true
    end

    it 'should assign false to @have_ir_notif if user have no incident report notification' do
      get :index, params: { type: 'ir' }
      expect(assigns(:notifications).count).to eq 0
      expect(assigns(:have_ir_notif)).to eq false
    end
  end
end
