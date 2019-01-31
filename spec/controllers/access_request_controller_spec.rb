require 'spec_helper'

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
