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
describe AccessRequestsController, type: :controller do
	context 'user access' do
		let(:user) { FactoryGirl.create(:user)}
		let(:access_request) { FactoryGirl.create(:access_request, user: user)}

		before :each do
			controller.request.env['devise.mapping'] = Devise.mappings[:user]
			sign_in user
		end	

		describe 'GET #index' do

      it 'populates an array of all access requests' do
        get :index
        expect(assigns(:access_requests)).to match_array([access_request])
      end
      it 'renders the :index view' do
        get :index
        expect(:response).to render_template :index
      end

      context "when download as csv" do
        render_views
        let(:csv_string)  {  access_request.to_csv }
        let(:csv_options) { {filename: "Access Requests.csv", disposition: 'attachment', type: 'text/csv'} }
        let(:params) { {format: "csv", page: 1, per_page: 20}  }
        let(:csv_headers) {AccessRequest.to_comma_headers.to_csv}

        it "should return current page when downloading an attachment" do
          get :index, params
          expect(response.header['Content-Type']).to eq('text/csv')
        end

        it "should contain button for download csv" do
          get :index
          expect(response.body).to include("Download Access Request")
        end

        it "should render response body with access request data as csv" do
          ar = FactoryGirl.create(:access_request, employee_name: 'Test')
          get :index, { format: "csv", q: { employee_name_cont: 'Test' }}
          expect(response.body).to eq(csv_headers+ar.to_comma.to_csv)
        end
      end

    end
	end
end
