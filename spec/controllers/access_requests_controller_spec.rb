require 'spec_helper'

describe AccessRequestsController, type: :controller do
  context 'user access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:access_request) {access_request = FactoryGirl.create(:access_request, user: user)}
    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET #new' do
      it 'assigns a new Access Request to @access_request' do
        get :new
        expect(assigns(:access_request)).to be_a_new(AccessRequest)
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end

      it 'returns total of active user' do
        user_locked = FactoryGirl.create(:user)
        user_locked.update_attribute(:locked_at, Time.current)
        get :new

        expect(assigns(:users).count).to match 1
      end

      it 'returns total of approver_ar user' do
        approver1 = FactoryGirl.create(:approver_ar)
        approver2 = FactoryGirl.create(:approver_ar)
        get :new

        expect(assigns(:approvers).count).to match 2
      end
    end

    describe 'GET #show' do
      it 'assigns the requested access request to @access_request' do
        get :show, id: access_request
        expect(assigns(:access_request)).to eq access_request
      end

      it 'renders the :show template' do
        get :show, id: access_request
        expect(response).to render_template :show
      end

      it 'get all the username from active user' do
        get :show, id: access_request

        expect(assigns(:usernames)).to include user.email.split('@')[0]
      end
    end
  end
end
