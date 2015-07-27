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

	describe 'GET #index' do
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
			before :each do
				user = FactoryGirl.create(:user)
				cr = FactoryGirl.create(:change_request, user: user)
				@cr_list = [cr.id]
			end

			it 'saves the new cab in the database' do
				expect{
					post :create, cab: FactoryGirl.attributes_for(:cab), cr_list: @cr_list
				}.to change(Cab, :count).by(1)
			end
		end

		context "with invalid attributes" do
			it 'doesnt save the new cab in the database' do
				expect{
					post :create, cab: FactoryGirl.attributes_for(:invalid_cab)
				}.to_not change(Cab, :count)
			end
		end
	end

	describe 'PATCH #update' do
		before :each do
			@cab = FactoryGirl.create(:cab)
		end

		context 'valid attributes' do
			it "changes @cab's attributes" do
				time = Time.now + 7200
				patch :update, id: @cab,
				  cab: FactoryGirl.attributes_for(:cab, meet_date: time),
				  cr_list: [], all_cr_list: []
				@cab.reload
				expect(@cab.meet_date.to_i).to eq(time.to_i)
			end
		end

		context 'invalid attributes' do
			it "doesnt change the @cab's attributes" do
				time = Time.now - 3600
				patch :update, id: @cab,
				  cab: FactoryGirl.attributes_for(:cab, meet_date: time),
				  cr_list: [], all_cr_list: []
				@cab.reload
				expect(@cab.meet_date.to_i).to_not eq(time.to_i)
			end
		end
	end

	describe 'DELETE #destroy' do
		before :each do
      @cab = FactoryGirl.create(:cab)
    end

    it "deletes the cab" do
      expect{
        delete :destroy, id: @cab
      }.to change(Cab, :count).by(-1)
    end
  end
  
end
