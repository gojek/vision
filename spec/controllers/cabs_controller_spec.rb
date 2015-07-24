require 'spec_helper'

describe CabsController do
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user]
		user = FactoryGirl.create(:user)
		sign_in user
	end

	describe 'GET #show' do
		it 'assigns the requested cab to @cab' do
			cab = FactoryGirl.create(:cab)
			get :show, id: cab
			expect(assigns(:cab)).to eq cab
		end

		it 'renders the :show template' do
			cab = FactoryGirl.create(:cab)
			get :show, id: cab
			expect(response).to render_template :show
		end
	end

	describe 'GET#index' do
		it 'populates an array of all cabs' do
			cab = FactoryGirl.create(:cab)
			other_cab = FactoryGirl.create(:cab)
			get :index
			expect(assigns(:cabs)).to match_array([cab, other_cab])
		end

		it 'renders the :index view' do
			get :index
			expect(:response).to render_template :index
		end
	end

	describe 'GET #new' do
		it 'assigns a new Cab to @cab' do
			get :new
			expect(assigns(:cab)).to be_a_new(Cab)
		end

		it 'assigns all cab-free Change Request to @change_requests' do
			get :new
			cab = FactoryGirl.create(:cab)
			cr = FactoryGirl.create(:change_request)
			other_cr = FactoryGirl.create(:change_request, cab: cab)
			expect(assigns(:change_requests)).to match_array([cr])
		end

		it 'renders the :new template' do
			get :new
			expect(response).to render_template :new
		end
	end

	describe 'GET #edit' do
		it 'assigns the requested cab to @cab' do
			cab = FactoryGirl.create(:cab)
			get :edit, id: cab
			expect(assigns(:cab)).to eq cab
		end

		it 'renders the :edit template' do
			cab = FactoryGirl.create(:cab)
			get :edit, id: cab
			expect(response).to render_template :edit
		end
	end

	describe 'POST #create' do
		context "with valid attributes" do
		end

		context "with invalid attributes" do
		end

		
	end
end
