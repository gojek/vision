require 'spec_helper'

describe AccessRequestsController, type: :controller do
  context 'user access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:incident_report) {incident_report = FactoryGirl.create(:incident_report, user: user)}
    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET #new' do
      it 'assigns a new Access Request to @access_requests' do
        get :new
        expect(assigns(:access_request)).to be_a_new(AccessRequest)
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

  end
end
