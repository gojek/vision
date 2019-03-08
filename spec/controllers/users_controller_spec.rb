require 'spec_helper'

describe UsersController, type: :controller do
  context 'user access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:waiting) {FactoryGirl.create(:waiting_user)}
    let(:reject) {FactoryGirl.create(:rejected_user)}
    let(:admin) {FactoryGirl.create(:admin)}
    let(:pending_user) {FactoryGirl.create(:pending_user)}
    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
    end

    describe 'user try to sign in' do
      it 'is sign_in rejected user' do
        sign_in reject
        expect(response.status).to eq 200
      end

      it 'is sign_in pending user' do
        sign_in pending_user
        expect(response.status).to eq 200
      end

      it 'is sign_in waiting approval user' do
        sign_in waiting
        expect(response.status).to eq 200
      end

      it 'is sign_in approved user' do
        sign_in user
        expect(response.status).to eq 200
      end
    end

    describe 'put #approving and #rejecting user' do
      it 'approving user' do
        sign_in admin

        put :approve_user, :id => waiting.id
        expect(response).to redirect_to(users_path)
      end

      it 'rejecting user' do
        admin = FactoryGirl.create(:admin)
        sign_in admin

        put :reject_user, :id => waiting.id
        expect(response).to redirect_to(users_path)
      end
    end

    describe 'get #index' do
      it 'is admin accessing default index page' do
        sign_in admin
        get :index

        expect(assigns(:users)).not_to be_empty
      end

      it 'is non admin accessing default index page' do
        sign_in user
        get :index

        expect(response).to redirect_to(root_path)
      end

      it 'is admin accessing filter index page' do
        FactoryGirl.create(:waiting_user)
        sign_in admin
        get :index, q: {is_approved_eq: 3}
        expect(assigns(:users).size).to eq 1
      end
    end

    it 'rejected user is trying to access users page' do
      sign_in reject
      get :index

      expect(response).to redirect_to(signin_path)
    end

    it 'waiting user is trying to access users page' do
      sign_in waiting
      get :index

      expect(response).to redirect_to(signin_path)
    end
  end
end
