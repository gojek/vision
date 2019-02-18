require 'spec_helper'

describe AccessRequestsController, type: :controller do 
  describe "requestor access" do
    let(:user) { FactoryGirl.create(:user)}
    let(:access_request) { FactoryGirl.create(:access_request)}

    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe "GET #index" do
      it "populates all access requests if no params passed" do
        get :index
        expect(assigns(:access_requests)).to match_array([access_request])
      end

      it "populates all access requests if no params passed inluding new access request" do
        other_ar = FactoryGirl.create(:access_request)
        get :index
        expect(assigns(:access_requests)).to match_array([access_request, other_ar])
      end

      describe "spesific access request filtered by params" do
        it "should be render list of access_request with matching attribute value -> filtered by request_type" do
          access_request.update(request_type: 'Create')
          get :index, q: { request_type_eq: 'Create' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by request_type (1 matches)" do
          access_request.update(request_type: 'Create')
          other_ar = FactoryGirl.create(:access_request, request_type: 'Modify')
          get :index, q: { request_type_eq: 'Create' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by request_type (2 matches)" do
          access_request.update(request_type: 'Create')
          other_ar = FactoryGirl.create(:access_request, request_type: 'Create')
          get :index, q: { request_type_eq: 'Create' }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        describe "should be render list of access_requests that relevant to current user " do
          it "user as a requester " do
            get :index, q: { type: 'relevant' }
            expect(assigns(:access_requests)).to match_array([access_request])
          end

          it "user as a collaborator" do 
            access_request.update(user: FactoryGirl.create(:user), collaborators: [user])
            get :index, q: { type: 'relevant' }
            expect(assigns(:access_requests)).to match_array([access_request])
          end

          it "user as a approver" do 
            approver = FactoryGirl.create(:access_request_approval, user: user)
            access_request.update(user: FactoryGirl.create(:user), approvals: [approver]  )
            get :index, q: { type: 'relevant' }
            expect(assigns(:access_requests)).to match_array([access_request])
          end

          describe "when user click need to approval" do
            it "should render list of access_requests that need approve from current user" do
              approver = FactoryGirl.create(:access_request_approval, user: user)
            access_request.update(user: FactoryGirl.create(:user), approvals: [approver]  )
            get :index, q: { type: 'approval' }
            expect(assigns(:access_requests)).to match_array([access_request])
            end
          end
        end

      end

      describe "no match access request given spesific params" do
        it "should render empty list of access requests -> filtered by request type" do
          access_request.update(request_type: 'Delete')
          get :index, q: { request_type_eq: 'Create'}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end

        it "should render empty list of access requests -> filtered by access type" do
          access_request.update(access_type: 'Permanent')
          get :index, q: { access_type_eq: 'Temporary'}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end
      end
    end
  end
end