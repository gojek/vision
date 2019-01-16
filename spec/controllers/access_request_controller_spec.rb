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

        it "should be render list of access_request with matching attribute value -> filtered by access_type" do
          access_request.update(access_type: 'Permanent')
          get :index, q: { access_type_eq: 'Permanent' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by access_type (1 matches)" do
          other_ar = FactoryGirl.create(:access_request, access_type: 'Temporary', start_date: Time.now, end_date: Time.now + 3.days)
          get :index, q: { access_type_eq: 'Temporary' }
          expect(assigns(:access_requests)).to match_array([other_ar])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by access_type (2 matches)" do
          access_request.update(access_type: 'Permanent')
          other_ar = FactoryGirl.create(:access_request, access_type: 'Permanent')
          get :index, q: { access_type_eq: 'Permanent' }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_name" do
          access_request.update(employee_name: 'Name 1')
          get :index, q: { employee_name_cont: 'name' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_name (1 matches)" do
          access_request.update(employee_name: 'Employee Name')
          other_ar = FactoryGirl.create(:access_request, employee_name: 'fai')
          get :index, q: { employee_name_cont: 'fa' }
          expect(assigns(:access_requests)).to match_array([other_ar])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_name (2 matches)" do
          access_request.update(employee_name: 'Employee 1')
          other_ar = FactoryGirl.create(:access_request, employee_name: 'Employee 2')
          get :index, q: { employee_name_cont: 'emplo' }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_position" do
          access_request.update(employee_position: 'Bussiness')
          get :index, q: { employee_position_cont: 'bussiness' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_position (1 matches)" do
          access_request.update(employee_position: 'CEO')
          other_ar = FactoryGirl.create(:access_request, employee_position: 'intern')
          get :index, q: { employee_position_cont: 'intern' }
          expect(assigns(:access_requests)).to match_array([other_ar])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_position (2 matches)" do
          access_request.update(employee_position: 'Software engineering intern')
          other_ar = FactoryGirl.create(:access_request, employee_position: 'UI/UX intern')
          get :index, q: { employee_position_cont: 'intern' }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_email_address" do
          access_request.update(employee_email_address: 'employee@***REMOVED***')
          get :index, q: { employee_email_address_cont: 'employee@***REMOVED***' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_email_address (1 matches)" do
          access_request.update(employee_email_address: 'engineering@***REMOVED***')
          other_ar = FactoryGirl.create(:access_request, employee_email_address: 'employee@***REMOVED***')
          get :index, q: { employee_email_address_cont: 'employee@***REMOVED***' }
          expect(assigns(:access_requests)).to match_array([other_ar])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_email_address (2 matches)" do
          access_request.update(employee_email_address: 'engineering@***REMOVED***')
          other_ar = FactoryGirl.create(:access_request, employee_email_address: 'employee@***REMOVED***')
          get :index, q: { employee_email_address_cont: '@***REMOVED***' }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_department" do
          access_request.update(employee_department: 'Engineering')
          get :index, q: { employee_department_cont: 'Engineering' }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_department (1 matches)" do
          access_request.update(employee_department: 'Engineering')
          other_ar = FactoryGirl.create(:access_request, employee_department: 'Finance')
          get :index, q: { employee_department_cont: 'Finance' }
          expect(assigns(:access_requests)).to match_array([other_ar])
          expect(assigns(:access_requests).count).to eq 1
        end

        it "should be render list of access_request with matching attribute value -> filtered by employee_department (2 matches)" do
          access_request.update(employee_department: 'Finance')
          other_ar = FactoryGirl.create(:access_request, employee_department: 'Finance')
          get :index, q: { employee_department_cont: 'Finance' }
          expect(assigns(:access_requests)).to match_array([access_request, other_ar])
          expect(assigns(:access_requests).count).to eq 2
        end

        it "should be render list of access_request between specified creted_at time between" do
          access_request.update(created_at: Time.now - 1.day)
          get :index, q: { created_at_gteq: Time.now - 3.days, created_at_lteq: Time.now }
          expect(assigns(:access_requests)).to match_array([access_request])
          expect(assigns(:access_requests).count).to eq 1 
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

        it "should render empty list of access requests -> filtered by employee name" do
          access_request.update(employee_name: 'Name 1')
          get :index, q: { employee_name_cont: 'f'}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end

        it "should render empty list of access requests -> filtered by employee position" do
          access_request.update(employee_position: 'Intern')
          get :index, q: { employee_position_cont: 'Bussiness'}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end

        it "should render empty list of access requests -> filtered by employee email address" do
          access_request.update(employee_email_address: 'intern@***REMOVED***')
          get :index, q: { employee_email_address_cont: 'fulltime@***REMOVED***'}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end

        it "should render empty list of access requests -> filtered by employee department" do
          access_request.update(employee_department: 'Engineering')
          get :index, q: { employee_department_cont: 'Bussiness'}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end

        it "should render empty list of access requests -> filtered by created_at between" do
          access_request.update(created_at: Time.now)
          get :index, q: { created_at_lteq: 2.days.ago, created_at_gteq: 3.days.ago}
          expect(assigns(:access_requests)).to match_array([])
          expect(assigns(:access_requests).count).to eq 0
        end



      end
    end
  end
end