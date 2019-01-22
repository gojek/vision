require 'spec_helper'

describe UsersController, type: :controller do


  describe 'pending user access vision' do
    let(:user) { FactoryGirl.create(:pending_user)}
    let(:attributes) {FactoryGirl.attributes_for(:access_request)}
    let(:approver) {FactoryGirl.create(:approver)}


    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      FactoryGirl.create(:user, email: 'ika.​muiz@midtrans.​com')
      sign_in user
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
    end

    describe 'POST #/register' do

      describe 'if success' do
        it 'should be redirect_to to sign in page' do
          post :create, access_request: attributes, approvers_list: [approver], collaborators_list: []
          expect(response).to redirect_to signin_path
        end

        it 'should be redirect_to to sign in page and contains some success flash message' do
          post :create, access_request: attributes, approvers_list: [approver], collaborators_list: []
          expect(flash[:success]).to eq('Request has been created and waiting for approval. You\'ll get notification once its approved')
        end

        it 'should be create a new access request' do
          expect {
            post :create, access_request: attributes, approvers_list: [approver], collaborators_list: []
          }.to change(AccessRequest, :count).by 1
        end

        it 'should be update current_user\'s is_approved = 2' do
          post :create, access_request: attributes, approvers_list: [approver], collaborators_list: []
          user.reload
          expect(user.is_approved).to eq 2
        end 
      end
      

      describe 'if error, should contains error messages' do
        render_views

        it 'should be contains message that employee name can\'t be blank -> if employee_name is empty' do

          post :create, 
            access_request: FactoryGirl.attributes_for(:access_request, employee_name: ''),
            approvers_list: [approver], collaborators_list: []

          expect(response.body).to include('Employee name can&#39;t be blank')
        end

        it 'should be contains message that employee position can\'t be blank -> if employee_position is empty' do

          post :create, 
            access_request: FactoryGirl.attributes_for(:access_request, employee_position: ''),
            approvers_list: [approver], collaborators_list: []

          expect(response.body).to include('Employee position can&#39;t be blank')
        end

        it 'should be contains message that employee department can\'t be blank -> if employee_department is empty' do

          post :create, 
            access_request: FactoryGirl.attributes_for(:access_request, employee_department: ''),
            approvers_list: [approver], collaborators_list: []

          expect(response.body).to include('Employee department can&#39;t be blank')
        end

        it 'should be contains message that employee phone can\'t be blank -> if employee_phone is empty' do

          post :create, 
            access_request: FactoryGirl.attributes_for(:access_request, employee_phone: ''),
            approvers_list: [approver], collaborators_list: []

          expect(response.body).to include('Employee phone can&#39;t be blank')
        end

        it 'should be contains message that business justification can\'t be blank -> if business justification is empty' do

          post :create, 
            access_request: FactoryGirl.attributes_for(:access_request, business_justification: ''),
            approvers_list: [approver], collaborators_list: []

          expect(response.body).to include('Business justification can&#39;t be blank')
        end
      end
    end


  end


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
        expect(response).to redirect_to signin_path
      end

      it 'is sign_in waiting approval user' do
        sign_in user
        expect(response.status).to eq 200
      end

      it 'is sign_in approved user' do
        sign_in waiting
        expect(response).to redirect_to signin_path
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

        expect(response.status).to eq 200
      end

      it 'is non admin accessing default index page' do
        sign_in user
        get :index

        expect(response).to redirect_to(root_path)
      end

      it 'is admin accessing filter index page' do
        sign_in admin
        get :index, q: {is_approved_eq: 2}

        expect(response.body).to include 'Approved'
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
