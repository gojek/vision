require 'rails_helper'


RSpec.describe IncidentReportsController, type: :controller do
  
  context 'user access' do
    let(:user) {FactoryBot.create(:user)}
    let(:incident_report) {incident_report = FactoryBot.create(:incident_report, user: user)}
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in incident_report.user
    end
    describe 'GET #show' do
      it 'assigns the requested incident report to @incident_report' do
        get :show, params: { id: incident_report }
        expect(assigns(:incident_report)).to eq incident_report
      end

      it 'renders the :show template' do
        get :show, params: { id: incident_report }
        expect(response).to render_template :show
      end
    end
    describe 'GET #index' do
      it 'populates an array of all incident reports' do
        get :index
        expect(assigns(:incident_reports)).to match_array([incident_report])
      end
      it 'renders the :index view' do
        get :index
        expect(:response).to render_template :index
      end

      context "When download as csv" do
        let(:csv_string)  {  incident_report.to_csv }
        let(:csv_options) { {filename: "incident_report.csv", disposition: 'attachment', type: 'text/csv; charset=utf-8; header=present'} }
        let(:params) { {format: "csv", page: 1, per_page: 20}  }

        it "should return current page when downloading an attachment" do
          get :index, params: params
          expect(response.header['Content-Type']).to eq('text/csv')
        end
      end

    end

    describe 'GET #new' do
      it 'assigns a new Incident Report to @IncidentReport' do
        get :new
        expect(assigns(:incident_report)).to be_a_new(IncidentReport)
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
    end

    describe 'GET #edit' do
      it 'assigns the requested incident report to @incident report' do
        get :edit, params: { id: incident_report }
        expect(assigns(:incident_report)).to eq incident_report
      end

      it 'renders the :edit template' do
        get :edit, params: { id: incident_report }
        expect(response).to render_template :edit
      end

      it 'returns total of active user' do
        user_locked = FactoryBot.create(:user)
        user_locked.update_attribute(:locked_at, Time.current)
        get :edit, params: { id: incident_report }

        expect(assigns(:users).count).to match 1
      end
    end

    describe 'POST #create' do
      context "with valid attributes" do
        it 'saves the new incident report in the database' do
          expect{
            post :create, params: { incident_report: FactoryBot.attributes_for(:incident_report) }
          }.to change(IncidentReport, :count).by(1)
        end
      end

      context "with invalid attributes" do
        it 'doesnt save the new incident report in the database' do
          expect{
            post :create, params: { incident_report: FactoryBot.attributes_for(:invalid_incident_report, source: 'source') }
          }.to_not change(IncidentReport, :count)
        end
      end
    end

    describe 'PATCH #update' do
      context 'valid attributes' do
        it "changes @incident_report's attributes" do
          source = 'External'
          patch :update, params: { id: incident_report,
            incident_report: FactoryBot.attributes_for(:incident_report_with_reason_update, source: source).except(:user) }
          incident_report.reload
          expect(incident_report.source).to eq(source)
        end
      end

      context 'invalid attributes' do
        it "doesnt change the @incidnet report's attributes" do
          source = 'source'
          patch :update, params: { id: incident_report,
            incident_report: FactoryBot.attributes_for(:incident_report_with_reason_update, source: source).except(:user) }
          incident_report.reload
          expect(incident_report.source).to_not eq(source)
        end
      end
      context 'unauthorized user' do
        before :each do
          @other_incident_report = FactoryBot.create(:incident_report, user:FactoryBot.create(:user))
        end
        it "won't save in the database" do
          source = 'External'
          patch :update, params: { id: @other_incident_report,
            incident_report: FactoryBot.attributes_for(:incident_report, source: source) }
          @other_incident_report.reload
          expect(@other_incident_report.source).to_not eq(source)
        end
      end
    end
    describe 'DELETE #destroy' do
      before :each do
        @incident_report = FactoryBot.create(:incident_report, user: user)
      end
      it "deletes the incident report" do
        expect{
          delete :destroy, params: { id: @incident_report }
        }.to change(IncidentReport, :count).by(-1)
      end
    end
  end

  context 'admin access' do
    let(:user) {FactoryBot.create(:user)}
    let(:incident_report) {FactoryBot.create(:incident_report, user:user)}
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @admin = FactoryBot.create(:admin)
      sign_in @admin
    end

    describe 'GET #edit' do
      it 'assigns the requested incident report to @incident report' do
        get :edit, params: { id: incident_report }
        expect(assigns(:incident_report)).to eq incident_report
      end

      it 'renders the :edit template' do
        get :edit, params: { id: incident_report }
        expect(response).to render_template :edit
      end
    end

    describe 'DELETE #destroy' do
      before :each do
        @incident_report = FactoryBot.create(:incident_report, user:user)
      end
      it "deletes the incident report" do
        expect{
          delete :destroy, params: { id: @incident_report }
        }.to change(IncidentReport, :count).by(-1)
      end
    end

    describe 'GET #search' do
      it 'render search view' do
        get :search, params: { search: "asd" }

        expect(response.body).to match /0 results found/im
      end

      it 'redirect to index if search a blank string' do
        get :search, params: { search: "" }
        expect(response).to redirect_to(incident_reports_path)
      end

      it 'returns search result' do
        incident_report = FactoryBot.create(:incident_report)
        
        get :search, params: { search: "Service" }
        
        expect(assigns(:search)).to match_array(incident_report)
      end

      it 'returns search pagination result' do
        incident_report = FactoryBot.create_list(:incident_report, 10)

        get :search, params: { search: "Service", per_page: 5 }

        expect(assigns(:search).total_pages).to match 2
      end
    end

    describe 'PATCH #update' do
      context 'valid attributes' do
        it "changes @incident_report's attributes" do
          source = 'External'
          patch :update, params: { id: incident_report,
            incident_report: FactoryBot.attributes_for(:incident_report_with_reason_update, source: source).except(:user) }
          incident_report.reload
          expect(incident_report.source).to eq(source)
        end
      end

      context 'invalid attributes' do
        it "doesnt change the @incident_report's attributes" do
          source = 'source'
          patch :update, params: { id: incident_report,
            incident_report: FactoryBot.attributes_for(:incident_report_with_reason_update, source: source).except(:user) }
          incident_report.reload          
          expect(incident_report.source).to_not eq(source)
        end
      end
    end

  end
end
