require 'spec_helper'

describe UsersController, type: :controller do
  context 'user access' do
    let(:user) {FactoryGirl.create(:user)}
    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it 'is sign_in rejected user' do
      reject = FactoryGirl.create(:rejected_user)
      sign_in reject

      expect(response.status).to eq 200
    end

    it 'is sign_in waiting approval user' do
      sign_in user

      expect(response.status).to eq 200
    end

    it 'is sign_in approved user' do
      waiting = FactoryGirl.create(:waiting_user)
      sign_in waiting
      expect(response.status).to eq 200
      # expect(flash[:alert]).to match 'Your account is not yet approved to open Vision'
    end

    it 'approving user' do
      admin = FactoryGirl.create(:admin)
      sign_in admin
      waiting = FactoryGirl.create(:waiting_user)

      put :approve_user, :id => waiting.id
      expect(response).to redirect_to(users_path)
    end

    it 'rejecting user' do
      admin = FactoryGirl.create(:admin)
      sign_in admin
      waiting = FactoryGirl.create(:waiting_user)

      put :reject_user, :id => waiting.id
      expect(response).to redirect_to(users_path)
    end

    # it 'assigns a new Access Request to @access_request' do
    #   get :new
    #   expect(assigns(:access_request)).to be_a_new(AccessRequest)
    # end

    # it 'renders the :new template' do
    #   get :new
    #   expect(response).to render_template :new
    # end

    # describe 'GET #show' do
    #   it 'assigns the requested access request to @access_request' do
    #     get :show, id: access_request
    #     expect(assigns(:access_request)).to eq access_request
    #   end

    #   it 'renders the :show template' do
    #     get :show, id: access_request
    #     expect(response).to render_template :show
    #   end
    # end

  end
end
