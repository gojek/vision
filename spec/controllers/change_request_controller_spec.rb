require 'spec_helper'

describe ChangeRequestsController do
  before :all do
    SolrResultStub = Struct.new("SolrResultStub", :results)
  end

  describe 'requestor access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:approver) {FactoryGirl.create(:approver)}
    let(:change_request) {FactoryGirl.create(:change_request, user: user)}

    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET #show' do
      it 'assigns the requested Change Request to @CR' do
        get :show, id: change_request
        expect(assigns(:change_request)).to eq change_request
      end

      it 'assigns change request statuses for change request lifeline' do
        get :show, id: change_request
        expect(assigns(:cr_statuses)).to eq change_request.change_request_statuses
      end
    end

    describe 'GET #index' do
      it "populate all current user's Change Request if no param is passed" do
        other_cr = FactoryGirl.create(:change_request)
        get :index
        expect(assigns(:change_requests)).to match_array([change_request, other_cr])
      end

      it "populate current user's Change Request based on tag that selected" do
        change_request.update(tag_list: 'tag')
        other_cr = FactoryGirl.create(:change_request, user: user)
        get :index, tag_list: 'tag'
        expect(assigns(:change_requests)).to match_array([change_request])
      end

      it 'exporting specific cr filtered by q param if using tag filter' do
        change_request.update(priority: 'Urgent')
        get :index, q: {priority: 'Urgent'}
        expect(assigns(:change_requests)).to match_array([change_request])
      end

      context 'when sending get index with relevant params' do
        let(:other_user) {FactoryGirl.create(:user)}
        let(:new_change_request) {FactoryGirl.create(:change_request, user: user)}
        let(:other_change_request) {FactoryGirl.create(:change_request, user: other_user)}
        it 'should not populate change requests that have no relevancy to me' do
          change_request.reload
          new_change_request.reload
          get :index, type: 'relevant'
          expect(assigns(:change_requests)).to match_array([change_request, new_change_request])
        end
        it 'should populate change requests where I am an associated user' do
          change_request.reload
          new_change_request.reload
          other_change_request.update(associated_user_ids: [user.id])
          other_change_request.reload
          get :index, type: 'relevant'
          expect(assigns(:change_requests)).to match_array([change_request, other_change_request, new_change_request])
        end

      end

      context 'when exporting fulltext search results' do
        let(:change_request) {FactoryGirl.create(:change_request, business_justification: 'asdasd')}
        let(:other_cr) {FactoryGirl.create(:change_request, business_justification: 'asdasd')}

        before :each do
          allow(ChangeRequest).to receive(:solr_search).and_return(SolrResultStub.new([change_request, other_cr]))
        end

        it 'exporting specific cr from fulltext results' do
          get :index, format: :csv, search: "asdasd"
          expect(assigns(:change_requests)).to match_array([change_request, other_cr])
        end

        it 'call fulltext search solr function' do
          expect(ChangeRequest).to receive(:solr_search)
          get :index, format: :csv, search: "asdasd"
        end
      end
    end

    describe 'GET #new' do
      it 'assigns a new Change Request to @change_request' do
        get :new
        expect(assigns(:change_request)).to be_a_new(ChangeRequest)
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested ChangeRequest to @change_request if current user is the owner of the requested ChangeRequest' do
        get :edit, id: change_request
        expect(assigns(:change_request)).to eq change_request
      end

      it 'will redirect to Change Request List if current user is the owner of the requested ChangeRequest' do
        cr = FactoryGirl.create(:change_request)
        get :edit, id: cr
        response.should redirect_to change_requests_url
      end
    end

  	describe 'GET #duplicate' do
  		it 'will create a duplicate change request with empty implementation and grace period dates' do
  		  get :duplicate, id: change_request
        expect(assigns(:change_request)).to_not be_valid
        expect(assigns(:change_request)).to be_a_new(ChangeRequest)
        expect(assigns(:change_request).user).to eq user
        expect(assigns(:change_request).schedule_change_date).to be nil
        expect(assigns(:change_request).planned_completion).to be nil
        expect(assigns(:change_request).grace_period_starts).to be nil
        expect(assigns(:change_request).grace_period_end).to be nil
  		end
  	end

    describe 'GET #create_hotfix' do
      let(:cr) {FactoryGirl.create(:rollbacked_change_request)}
      it 'redirects to change request index if specified CR is not rollbacked' do
        get :create_hotfix, id: change_request
        response.should redirect_to change_requests_url
      end

      it 'should render change request new page' do
        get :create_hotfix, id: cr
        expect(response).to render_template :new
        expect(assigns(:change_request)).to be_a_new(ChangeRequest)
        expect(assigns(:change_request)).to_not be_valid
      end

      it 'should set the rollbacked CR as a reference to the new CR' do
        get :create_hotfix, id: cr
        expect(assigns(:change_request).reference_cr_id).to eq cr.id
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        let(:attributes) {FactoryGirl.attributes_for(:change_request)}
        it 'saves the new CR in the database' do
          expect{
            post :create, change_request: attributes, implementers_list: [approver.id], testers_list: [approver.id] , approvers_list: [approver.id]
          }.to change(ChangeRequest, :count).by(1)
          cr = ChangeRequest.first
          expect(cr.implementers.count).to eq(1)
          expect(cr.testers.count).to eq(1)
        end

        it 'create new approval(s) for the new CR in the database' do
          expect{
            post :create, change_request: attributes, implementers_list: [approver.id], testers_list: [approver.id] , approvers_list: [approver.id]
          }.to change(Approval, :count).by(1)
        end

        it 'assigns associated_user' do
          post :create, change_request: attributes, implementers_list: [user.id], testers_list: [user.id] , approvers_list: [approver.id]
          expect(assigns(:change_request).associated_user_ids).to match_array([user.id, approver.id])
        end
      end

      context 'with invalid attributes' do
        it "doesn't save new CR in the database" do
          expect{
            post :create, change_request: FactoryGirl.attributes_for(:change_request, :invalid_change_request)
          }.to_not change(ChangeRequest, :count)
        end
      end
    end

    describe 'PATCH #update' do
      context 'valid attributes' do
        it "change @cr attributes" do
          note = "Note 1"
          update_attributes = FactoryGirl.attributes_for(:change_request, note: note)
          expect(update_attributes[:note]).to eq(note)
          patch :update , id: change_request.id, change_request: update_attributes, implementers_list: [approver.id], testers_list: [approver.id] , approvers_list: [approver.id]
          change_request.reload
          expect(change_request.note).to eq(note)
        end

        it 'assigns associated_user' do
          update_attributes = FactoryGirl.attributes_for(:change_request)
          patch :update , id: change_request.id, change_request: update_attributes, implementers_list: [user.id], testers_list: [user.id] , approvers_list: [approver.id]
          expect(assigns(:change_request).associated_user_ids).to match_array([user.id, approver.id])
        end
      end
      context 'invalid attributes' do
        it "doesnt change the @cr attribute" do
          scope = 'scope'
          patch :update, id: change_request,
          change_request: FactoryGirl.attributes_for(:change_request, scope: scope)
          change_request.reload
          expect(change_request.scope). to_not eq(scope)
        end
      end
    end
    describe 'DELETE # destroy' do
      before :each do
        @cr = FactoryGirl.create(:change_request,user:user)
      end
      it 'delete the change request' do
        expect{
          delete :destroy, id: @cr
          }.to change(ChangeRequest, :count).by(-1)
      end
    end

    describe 'GET #search' do
      it 'search change request using solr_search' do
        expect(ChangeRequest).to receive(:solr_search)
        get :search, search: "asd"
      end

      it 'redirect to index if search a blank string' do
        get :search, search: ""
        expect(response).to redirect_to(change_requests_path)
      end
    end
  end

  describe 'approver access' do
    let(:user) {FactoryGirl.create(:approver)}
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
      @cr = FactoryGirl.create(:change_request, user: user)
      @approval = Approval.create(user: user, change_request: @cr)
    end
     describe 'GET #index' do
     it "populate all current user's Change Request if no param is passed" do
        get :index
        expect(assigns(:change_requests)).to match_array([@cr])
      end

      it 'populate the list with change requests that you need to approve when submitted with approval params' do
        cr_other = FactoryGirl.create(:change_request)
        get :index, type: 'approval'
        expect(assigns(:change_requests)).to match_array([@cr])
      end
    end
    describe 'PUT #approve' do
      it 'will change approval to approve' do
        put :approve, id: @cr, notes: "good"

        @approval.reload
        expect(@approval.approve).to eq true
        expect(@approval.approval_date).to_not be_nil
        expect(@approval.approval_date.class).to eq(ActiveSupport::TimeWithZone)
      end
    end
     describe 'PUT #reject' do
      it 'will change approval to reject' do
        put :reject, id: @cr.id, notes: "Want to reject it for profit"
        @approval.reload
        expect(@approval.approve).to eq false
      end
    end
  end

  describe 'release manager acces' do
    let(:user) {FactoryGirl.create(:release_manager)}
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @cr = FactoryGirl.create(:change_request, user: user)
      @approval = Approval.create(user_id: user.id, change_request_id: @cr.id)
      sign_in user
    end
     describe 'GET #index' do
     it "populate all current user's Change Request if no param is passed" do
        get :index
        expect(assigns(:change_requests)).to match_array([@cr])
      end
    end
  end
end
