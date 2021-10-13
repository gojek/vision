require 'rails_helper'

RSpec.describe AccessRequestsController, type: :controller do
  context 'user access' do
    let(:user) {FactoryBot.create(:user)}
    let(:approver_ar) {FactoryBot.create(:approver_ar, email:'patrick.star@gmail.com')}
    let(:access_request) {access_request = FactoryBot.create(:access_request, user: user)}

    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe "GET #index" do
      it "populates all access requests if no params passed" do
        access_request.reload
        get :index
        expect(assigns(:access_requests)).to match_array([access_request])
      end

      it "populates all access requests if no params passed inluding new access request" do
        access_request.reload
        other_ar = FactoryBot.create(:access_request)
        get :index
        expect(assigns(:access_requests)).to match_array([access_request, other_ar])
      end

      describe "spesific access request filtered by params" do
        it "should be render list of access_request with matching attribute value -> filtered by request_type" do
          access_request.update(request_type: 'Create')
          get :index, params: { q: { request_type_eq: 'Create' } }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by request_type (1 matches)" do
          access_request.update(request_type: 'Create')
          other_ar = FactoryBot.create(:access_request, request_type: 'Modify')
          get :index, params: { q: { request_type_eq: 'Create' }}
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by request_type (2 matches)" do
          access_request.update(request_type: 'Create')
          other_ar = FactoryBot.create(:access_request, request_type: 'Create')
          get :index, params: { q: { request_type_eq: 'Create' } }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        describe "should be render list of access_requests that relevant to current user " do
          it "user as a requester " do
            access_request.reload
            get :index, params: { q: { type: 'relevant' }}
            expect(assigns(:access_requests)).to match_array([access_request])
          end

          it "user as a collaborator" do 
            access_request.update(user: FactoryBot.create(:user), collaborators: [user])
            get :index, params: { q: { type: 'relevant' }}
            expect(assigns(:access_requests)).to match_array([access_request])
          end

          it "user as a approver" do 
            approver = FactoryBot.create(:access_request_approval, user: user)
            access_request.update(user: FactoryBot.create(:user), approvals: [approver]  )
            get :index, params: { q: { type: 'relevant' }}
            expect(assigns(:access_requests)).to match_array([access_request])
          end

          describe "when user click need to approval" do
            it "should render list of access_requests that need approve from current user" do
              approver = FactoryBot.create(:access_request_approval, user: user)
            access_request.update(user: FactoryBot.create(:user), approvals: [approver]  )
            get :index, params: { q: { type: 'approval' }}
            expect(assigns(:access_requests)).to match_array([access_request])
            end
          end
        end

      end

      describe "no match access request given spesific params" do
        it "should render empty list of access requests -> filtered by request type" do
          access_request.update(request_type: 'Delete')
          get :index, params: { q: { request_type_eq: 'Create'} }
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end

        it "should render empty list of access requests -> filtered by access type" do
          access_request.update(access_type: 'Permanent')
          get :index, params: { q: { access_type_eq: 'Temporary'} }
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end
      end
    end

    describe 'POST #import_from_csv' do
      before :each do
        @request.env['devise.mapping'] = Devise.mappings[:approver_ar]
        sign_in approver_ar
      end
      describe "can upload csv" do
        before :each do
          @file = fixture_file_upload('files/valid_invalid.csv', 'text/csv')
        end

        it "check the total of valid access_request from csv" do
          post :import_from_csv, params: { :csv => @file }
          expect(assigns(:valid).count).to match(2)
        end

        it "check the total of invalid access_request from csv" do
          post :import_from_csv, params: { :csv => @file }
          expect(assigns(:invalid).count).to match(2)
        end
      end
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
        user_locked = FactoryBot.create(:user)
        user_locked.update_attribute(:locked_at, Time.current)
        get :new

        expect(assigns(:users).count).to match 1
      end

      it 'returns total of approver_ar user' do
        approver1 = FactoryBot.create(:approver_ar)
        approver2 = FactoryBot.create(:approver_ar)
        get :new

        expect(assigns(:approvers).count).to match 2
      end
    end

    describe 'GET #show' do
      it 'assigns the requested access request to @access_request' do
        get :show, params: { id: access_request }
        expect(assigns(:access_request)).to eq access_request
      end

      it 'renders the :show template' do
        get :show, params: { id: access_request }
        expect(response).to render_template :show
      end

      it 'get all the username from active user' do
        get :show, params: { id: access_request }
        expect(assigns(:usernames)).to include user.email.split('@')[0]
      end
    end

    describe 'GET #search' do
      it 'render search view' do
        get :search, params: { search: "asd" }

        expect(response.body).to match /0 results found/im
      end

      it 'redirect to index if search a blank string' do
        get :search, params: { search: "" }
        expect(response).to redirect_to(access_requests_path)
      end

      it 'returns search result' do
        access_request = FactoryBot.create(:access_request)
        
        get :search, params: { search: "Employee" }
        
        expect(assigns(:search)).to match_array(access_request)
      end

      it 'returns search pagination result' do
        access_request = FactoryBot.create_list(:access_request, 10)
        
        get :search, params: { search: "Employee", per_page: 5 }

        expect(assigns(:search).total_pages).to match 2
      end
    end
  end
end
