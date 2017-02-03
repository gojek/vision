require 'spec_helper'

describe IncidentReportsController, type: :controller do
	context 'user access' do
		let(:user) {FactoryGirl.create(:user)}
		let(:incident_report) {incident_report = FactoryGirl.create(:incident_report, user: user)}
		before :each do
			controller.request.env['devise.mapping'] = Devise.mappings[:user]
			sign_in user
		end
		describe 'GET #show' do
			it 'assigns the requested incident report to @incident_report' do
				get :show, id: incident_report
				expect(assigns(:incident_report)).to eq incident_report
			end

			it 'renders the :show template' do
				get :show, id: incident_report
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
		end

		describe 'GET #edit' do
			it 'assigns the requested incident report to @incident report' do
				get :edit, id: incident_report
				expect(assigns(:incident_report)).to eq incident_report
			end

			it 'renders the :edit template' do
				get :edit, id: incident_report
				expect(response).to render_template :edit
			end
		end

		describe 'POST #create' do
			context "with valid attributes" do
				it 'saves the new incident report in the database' do
					expect{
						post :create, incident_report: FactoryGirl.attributes_for(:incident_report)
					}.to change(IncidentReport, :count).by(1)
				end
			end

			context "with invalid attributes" do
				it 'doesnt save the new incident report in the database' do
					expect{
						post :create, incident_report: FactoryGirl.attributes_for(:invalid_incident_report)
					}.to_not change(IncidentReport, :count)
				end
			end
		end

		describe 'PATCH #update' do
			context 'valid attributes' do
				it "changes @incident_report's attributes" do
					source = 'External'
					patch :update, id: incident_report,
						incident_report: FactoryGirl.attributes_for(:incident_report, source: source)
					incident_report.reload
					expect(incident_report.source).to eq(source)
				end
			end

			context 'invalid attributes' do
				it "doesnt change the @incidnet report's attributes" do
					source = 'source'
					patch :update, id: incident_report,
						incident_report: FactoryGirl.attributes_for(:incident_report, source: source)
					incident_report.reload
					expect(incident_report.source).to_not eq(source)
				end
			end
			context 'unauthorized user' do
				before :each do
					@other_incident_report = FactoryGirl.create(:incident_report, user:FactoryGirl.create(:user))
				end
				it "won't save in the database" do
					source = 'External'
					patch :update, id: @other_incident_report,
						incident_report: FactoryGirl.attributes_for(:incident_report, source: source)
					@other_incident_report.reload
					expect(@other_incident_report.source).to_not eq(source)
				end
			end
		end
		describe 'DELETE #destroy' do
			before :each do
				@incident_report = FactoryGirl.create(:incident_report, user: user)
			end
			it "deletes the incident report" do
				expect{
					delete :destroy, id: @incident_report
				}.to change(IncidentReport, :count).by(-1)
			end
		end
	end

	context 'admin access' do
		let(:user) {FactoryGirl.create(:user)}
		let(:incident_report) {FactoryGirl.create(:incident_report, user:user)}
		before :each do
			@request.env['devise.mapping'] = Devise.mappings[:admin]
			@admin = FactoryGirl.create(:admin)
			sign_in @admin
		end

		describe 'GET #edit' do
			it 'assigns the requested incident report to @incident report' do
				get :edit, id: incident_report
				expect(assigns(:incident_report)).to eq incident_report
			end

			it 'renders the :edit template' do
				get :edit, id: incident_report
				expect(response).to render_template :edit
			end
		end

		describe 'DELETE #destroy' do
			before :each do
				@incident_report = FactoryGirl.create(:incident_report,user:user)
			end
			it "deletes the incident report" do
				expect{
					delete :destroy, id: @incident_report
				}.to change(IncidentReport, :count).by(-1)
			end
		end

		describe 'PATCH #update' do
			context 'valid attributes' do
				it "changes @incident_report's attributes" do
					source = 'External'
					patch :update, id: incident_report,
						incident_report: FactoryGirl.attributes_for(:incident_report, source: source)
					incident_report.reload
					expect(incident_report.source).to eq(source)
				end
			end

			context 'invalid attributes' do
				it "doesnt change the @incident_report's attributes" do
					source = 'source'
					patch :update, id: incident_report,
						incident_report: FactoryGirl.attributes_for(:incident_report, source: source)
					incident_report.reload
					expect(incident_report.source).to_not eq(source)
				end
			end
		end

	end
end
