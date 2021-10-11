require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'pending user access vision' do
    let(:user) { FactoryBot.create(:pending_user)}
    let(:attributes) {FactoryBot.attributes_for(:access_request)}
    let(:approver) {FactoryBot.create(:approver)}
    let(:waiting_user) {FactoryBot.create(:waiting_user)}
    let(:pending_user) {FactoryBot.create(:pending_user)}

    before :each do
      FactoryBot.create(:user).email
      FactoryBot.create(:master_approver).email
      FactoryBot.create(:user, email: 'vision@gmail.com')
      @request.env['devise.mapping'] = Devise.mappings[:pending_user]
      sign_in pending_user
    end

    describe 'GET #/register' do
      it 'should be return http status 200' do
        get :new
        expect(response.status).to eq(200)
      end

      it 'should be render :new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'is sign_in pending user' do
        sign_in pending_user
        expect(subject.current_user).to eq(pending_user)
      end
      
    end

    describe 'POST #/register' do
      describe 'if success' do
        it 'should be redirect_to to sign in page' do
          post :create, params: { access_request: attributes, approver_ids: [approver], collaborator_ids: [] }
          expect(response).to redirect_to signin_path
        end

        it 'should be redirect_to to sign in page and contains some success flash message' do
          post :create, params: { access_request: attributes, approver_ids: [approver], collaborator_ids: [] }
          expect(flash[:success]).to eq('Request has been created and waiting for approval. You\'ll get notification once its approved')
        end

        it 'should be create a new access request' do
          expect {
            post :create, params: { access_request: attributes, approver_ids: [approver], collaborator_ids: [] }
          }.to change(AccessRequest, :count).by 1
        end

        it 'should be update current_user\'s is_approved = 2' do
          post :create, params: { access_request: attributes }
          pending_user.reload
          expect(pending_user.is_approved).to eq 'need_approvals'
        end 
        
        it 'is sign_in approved user' do
          sign_in user
          expect(response.status).to eq 200
        end
      end
    end

  end


  describe 'user access' do
    let(:user) {FactoryBot.create(:user)}
    let(:waiting) {FactoryBot.create(:waiting_user)}
    let(:reject) {FactoryBot.create(:rejected_user)}
    let(:admin) {FactoryBot.create(:admin)}
    let(:pending_user) {FactoryBot.create(:pending_user)}

    describe 'put #approving and #rejecting user' do
      it 'approving user' do
        sign_in admin

        put :approve_user, params: { :id => waiting.id }
        expect(response).to redirect_to(users_path)
      end

      it 'rejecting user' do
        admin = FactoryBot.create(:admin)
        sign_in admin

        put :reject_user, params: { :id => waiting.id }
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
        FactoryBot.create(:waiting_user)
        sign_in admin
        get :index, params: { q: {is_approved_eq: 3} }
        expect(assigns(:users).size).to eq 1
      end

      it 'rejected user is trying to access users page' do
        sign_in reject
        get :index

        expect(response).to redirect_to(new_user_session_path)
      end

      it 'waiting user is trying to access users page' do
        sign_in waiting
        get :index

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "admin access" do
    let(:admin) {FactoryBot.create(:admin, is_approved: 3)}
    render_views

    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in admin
    end

    it 'is admin accessing default index page' do
      get :index
      expect(response.status).to eq 200
    end

    it 'is admin accessing filter index page' do
      FactoryBot.create(:user, is_approved: 3) # example user 1 instance
      get :index, params: { q: {is_approved_eq: 3} }
      expect(response.body).to include 'Approved'
    end
  end
end
