require 'spec_helper'

describe CabsController do
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user]
		user = FactoryGirl.create(:release_manager)
		sign_in user
	end

	describe 'GET #show' do
		before :each do
			@cab = FactoryGirl.create(:cab)
			@cr = FactoryGirl.create(:change_request, cab: @cab)
		end

		it 'assigns the requested cab to @cab' do
			get :show, id: @cab
			expect(assigns(:cab)).to eq @cab
		end

		it 'populates all cr that belong to requested cab to @current_change_requests' do
			get :show, id: @cab
			expect(assigns(:current_change_requests)).to match_array([@cr])
		end

		it 'renders the :show template' do
			get :show, id: @cab
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
		xit 'assigns a new Cab to @cab' do
			get :new
			expect(assigns(:cab)).to be_a_new(Cab)
		end

		xit 'populates all cab-free Change Requests to @change_requests' do
			get :new
			cab = FactoryGirl.create(:cab)
			cr = FactoryGirl.create(:change_request)
			other_cr = FactoryGirl.create(:change_request, cab: cab)
			expect(assigns(:change_requests)).to match_array([cr])
		end

		xit 'renders the :new template' do
			get :new
			expect(response).to render_template :new
		end
	end

	describe 'GET #edit' do
		before :each do
			@cab = FactoryGirl.create(:cab)
			@cr = FactoryGirl.create(:change_request, cab: @cab)
			@other_cr = FactoryGirl.create(:change_request)
		end
		xit 'assigns the requested cab to @cab' do
			get :edit, id: @cab
			expect(assigns(:cab)).to eq @cab
		end

		xit 'renders the :edit template' do
			get :edit, id: @cab
			expect(response).to render_template :edit
		end

		xit 'populates all cab-free Change Requests to @change_requests' do
			get :edit, id: @cab
			expect(assigns(:change_requests)).to match_array([@other_cr])
		end

		xit 'populates all cr that belong to requested cab to @current_change_requests' do
			get :edit, id: @cab
			expect(assigns(:current_change_requests)).to match_array([@cr])
		end
	end

	describe 'POST #create' do
		context "with valid attributes" do
			before :each do
				user = FactoryGirl.create(:user)
				@cr = FactoryGirl.create(:change_request, user: user)
				@cr_list = [@cr.id]
				CabsController.any_instance.stub(:arrange_google_calendar) {true}
			end

			xit 'saves the new cab in the database' do
				expect{
					post :create, cab: FactoryGirl.attributes_for(:cab), cr_list: @cr_list
				}.to change(Cab, :count).by(1)
			end

			xit 'assigns all cr in @cr_list to the newly created CAB' do
				post :create, cab: FactoryGirl.attributes_for(:cab, id: 1), cr_list: @cr_list
				@cr.reload
				expect(@cr.cab_id).to eq 1
			end
		end

		context "with invalid attributes" do
			xit 'doesnt save the new cab in the database' do
				expect{
					post :create, cab: FactoryGirl.attributes_for(:invalid_cab)
				}.to_not change(Cab, :count)
			end
		end
	end

	describe 'PATCH #update' do
		before :each do
			@cab = FactoryGirl.create(:cab)
			@cr = FactoryGirl.create(:change_request, cab: @cab)
			@other_cr = FactoryGirl.create(:change_request)
		end

		context 'valid attributes' do
			xit "changes @cab's attributes" do
				time = Time.now + 7200
				patch :update, id: @cab,
				  cab: FactoryGirl.attributes_for(:cab, meet_date: time),
				  cr_list: [], all_cr_list: []
				@cab.reload
				expect(@cab.meet_date.to_i).to eq(time.to_i)
			end

			xit "assigns all cr from @cr_list to the @cab" do
				time = Time.now + 7200
				patch :update, id: @cab,
				  cab: FactoryGirl.attributes_for(:cab, meet_date: time),
				  cr_list: [@other_cr], all_cr_list: [@cr]
				@other_cr.reload
				expect(@other_cr.cab).to eq @cab
			end

			xit "remove all cr from @all_cr_list from the @cab" do
				time = Time.now + 7200
				patch :update, id: @cab,
				  cab: FactoryGirl.attributes_for(:cab, meet_date: time),
				  cr_list: [@other_cr], all_cr_list: [@cr]
				@cr.reload
				expect(@cr.cab).to eq nil
			end
		end

		context 'invalid attributes' do
			xit "doesnt change the @cab's attributes" do
				time = Time.now - 3600
				patch :update, id: @cab,
				  cab: FactoryGirl.attributes_for(:cab, meet_date: time),
				  cr_list: [], all_cr_list: []
				@cab.reload
				expect(@cab.meet_date.to_i).to_not eq(time.to_i)
			end
		end
	end

	xit 'get_cabs will return all cab in json format ' do
		cab = FactoryGirl.create(:cab)
		get :get_cabs
		expect(response.body).to eq '[{"id":%s,"title":"CAB %s","start":"%s","end":"%s","url":"http://test.host/cabs/%s"}]' % [cab.id, cab.id, cab.meet_date.to_time.iso8601, cab.meet_date.to_time.iso8601, cab.id]

	end

	xit "get_change_requests will return current cab's change requests in json format" do
		cab = FactoryGirl.create(:cab)
		change_request = FactoryGirl.create(:change_request, cab: cab)
		get :get_change_requests, id: cab
		expect(response.body).to eq '[{"id":%s,"title":"%s","start":"%s","end":"%s"}]' % [change_request.id, change_request.change_summary, change_request.schedule_change_date.to_time.iso8601, change_request.planned_completion.to_time.iso8601, change_request.id]
	end

	describe 'POST #update_change_request' do
		xit 'save new planned completiom and schedule change date params for change request' do
			end_date = Time.now + 1.hour
			start_date = Time.now
			cab = FactoryGirl.create(:cab)
			change_request = FactoryGirl.create(:change_request, cab: cab)
			post :update_change_requests, id:cab,
				start1: start_date, end1: end_date
			change_request.reload
			expect(change_request.planned_completion.to_s).to eq(end_date.to_s)
			expect(change_request.schedule_change_date.to_s).to eq(start_date.to_s)


		end
	end

	describe 'DELETE #destroy' do
		before :each do
		  @cab = FactoryGirl.create(:cab)
		end
	    xit "deletes the cab" do
	      expect{
	        delete :destroy, id: @cab
	      }.to change(Cab, :count).by(-1)
	    end
  end

end
