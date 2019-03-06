require 'spec_helper'
require 'slack_notif'

describe ChangeRequestsController, type: :controller do
  before :all do
    SolrResultStub = Struct.new("SolrResultStub", :results)
  end

  describe 'requestor access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:approver) {FactoryGirl.create(:approver)}
    let(:change_request) {FactoryGirl.create(:submitted_change_request, user: user)}

    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
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

      it 'get all the username from active user' do
        get :show, id: change_request

        expect(assigns(:usernames)).to include user.email.split('@')[0]
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

      context "When download as csv" do
        let(:csv_string)  {  cr_current_page.to_csv }
        let(:csv_options) { {filename: "change_requests.csv", disposition: 'attachment', type: 'text/csv; charset=utf-8; header=present'} }
        let(:params) { {format: "csv", page: 1, per_page: 20}  }

        it "should return current page when downloading an attachment" do
          cr = FactoryGirl.create(:change_request)
          get :index, params
          #expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
          #  @controller.render nothing: true # to prevent a 'missing template' error
          #}
          expect(response.header['Content-Type']).to eq('text/csv')
          expect(response.body).to include('Request id', 'Change summary', 'Category', 'Type', 'Priority', 'Scope', 'Change requirement', 'Business justification', 'CR Status', 'Approval Status', 'Request date', 'Schedule change', 'Planned completion', 'Requestor', 'Tags', 'Approver', 'Testers', 'Implementers')
        end
      end

      context 'when sending get index with relevant params' do
        let(:other_user) {FactoryGirl.create(:user)}
        let(:new_change_request) {FactoryGirl.create(:submitted_change_request, user: user)}
        let(:other_change_request) {FactoryGirl.create(:submitted_change_request, user: other_user)}
        it 'should not populate change requests that have no relevancy to me' do
          change_request.reload
          new_change_request.reload
          get :index, type: 'relevant'
          expect(assigns(:change_requests)).to match_array([change_request, new_change_request])
        end

        it 'should populate change requests where I am an associated user' do
          change_request.reload
          new_change_request.reload
          other_change_request.update(tester_ids: [user.id])
          other_change_request.reload
          get :index, type: 'relevant'
          expect(assigns(:change_requests)).to match_array([change_request, other_change_request, new_change_request])
        end

      end

      context 'when exporting fulltext search results' do
        let(:change_request) {FactoryGirl.create(:submitted_change_request, business_justification: 'asdasd')}
        # ^ this change request is draft
        let(:other_cr) {FactoryGirl.create(:change_request, business_justification: 'asdasd')}
        before :each do
          allow(ChangeRequest).to receive(:solr_search).and_return(SolrResultStub.new([change_request, other_cr]))
        end

        it 'exporting specific cr from fulltext results' do
          get :search, search: "asdasd"
          expect(assigns(:search)).to match_array([[change_request, other_cr]])
        end

        it 'call fulltext search solr function' do
          expect(ChangeRequest).to receive(:solr_search)
          get :search, search: "asdasd"
        end
      end
    end

    describe 'GET #new' do
      it 'assigns a new Change Request to @change_request' do
        get :new
        expect(assigns(:change_request)).to be_a_new(ChangeRequest)
      end

      it 'returns total of active user' do
        user_locked = FactoryGirl.create(:user)
        user_locked.update_attribute(:locked_at, Time.current)
        get :new

        expect(assigns(:users).count).to match 1
      end

      it 'returns total of approver user' do
        approver = FactoryGirl.create(:approver)
        get :new
        puts

        expect(assigns(:approvers).count).to match 1
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested ChangeRequest to @change_request if current user is the owner of the requested ChangeRequest' do
        get :edit, id: change_request
        expect(assigns(:change_request)).to eq change_request
      end

    end

    describe 'GET #edit-graceperiod-notes' do
      it 'assigns the requested ChangeRequest to @change_request if current user is the owner of the requested ChangeRequest' do
        get :edit_grace_period_notes, id: change_request
        expect(assigns(:change_request)).to eq change_request
      end
    end

    describe 'GET #edit-implementation-notes' do
      it 'assigns the requested ChangeRequest to @change_request if current user is the owner of the requested ChangeRequest' do
        get :edit_implementation_notes, id: change_request
        expect(assigns(:change_request)).to eq change_request
      end

      it 'returns total of active user' do
        user_locked = FactoryGirl.create(:user)
        user_locked.update_attribute(:locked_at, Time.current)
        get :edit, id: change_request

        expect(assigns(:users).count).to match 6
      end

      it 'returns total of approver user' do
        approver = FactoryGirl.create(:approver)
        get :edit, id: change_request

        expect(assigns(:approvers).count).to match 3
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
        expect(response).to redirect_to(change_requests_url)
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
        let(:attributes) {FactoryGirl.attributes_for(:change_request, implementer_ids: [user.id, ""], tester_ids: [user.id, ""] , approver_ids: [approver.id, ""])}
        

        it 'saves the new CR in the database' do
          expect{
            post :create, change_request: attributes
          }.to change(ChangeRequest, :count).by(1)
          cr = ChangeRequest.first
          expect(cr.implementers.count).to eq(1)
          expect(cr.testers.count).to eq(1)
          expect(cr.aasm_state).to eq("submitted")
        end

        it 'create new approval(s) for the new CR in the database' do
          expect{
            post :create, change_request: attributes
          }.to change(Approval, :count).by(1)
        end

        it 'call slack notification library to send notification to slack veritrans about new cr' do
          expect_any_instance_of(SlackNotif).to receive(:notify_new_cr).with(an_instance_of(ChangeRequest))
          post :create, change_request: attributes, implementers_list: [approver.id], testers_list: [approver.id] , approver_ids: [approver.id]
        end
      end

      context 'with invalid attributes' do
        let(:attributes) {FactoryGirl.attributes_for(:change_request, :invalid_change_request)}
        it 'saves the new CR in the database as draft' do
          expect{
            post :create, change_request: attributes
          }.to change(ChangeRequest, :count).by(1)
          cr = ChangeRequest.last
          expect(cr.aasm_state).to eq "draft"
        end
      end

      context 'requestor change position' do
        let(:attributes) {FactoryGirl.attributes_for(:change_request)}
        it 'when requestor change position' do
          expect{
            post :create, change_request: attributes
          }.to change(ChangeRequest, :count).by(1)
          cr = ChangeRequest.last
          expect(cr.user.position).to eq (cr.requestor_position)
          user = cr.user
          user.position = 'Position 2'
          user.save
          expect(cr.requestor_position).not_to eq (user.position)
        end
      end

    end

    describe 'PATCH #update' do
      context 'valid attributes' do
        it "change @cr attributes" do
          note = "Note 1"
          update_attributes = FactoryGirl.attributes_for(:change_request, note: note)
          expect(update_attributes[:note]).to eq(note)
          patch :update , id: change_request.id, change_request: update_attributes
          change_request.reload
          expect(change_request.note).to eq(note)
        end

        it 'call slack notification library to send notification to slack veritrans about modified cr' do
          expect_any_instance_of(SlackNotif).to receive(:notify_update_cr).with(an_instance_of(ChangeRequest))
          update_attributes = FactoryGirl.attributes_for(:change_request, implementer_ids: [user.id, ""], tester_ids: [user.id, ""] , approver_ids: [approver.id, ""])
          patch :update , id: change_request.id, change_request: update_attributes
        end
      end
      context 'invalid attributes' do
        it "doesnt change the @cr attribute" do
          scope = 'scope'
          patch :update, id: change_request,
          change_request: FactoryGirl.attributes_for(:change_request, scope: scope)
          change_request.reload
          expect(change_request.scope).not_to eq(scope)
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
      @cr = FactoryGirl.create(:submitted_change_request, user: user)
      @approval = Approval.create(user: user, change_request: @cr)
    end
     describe 'GET #index' do
     it "populate all current user's Change Request if no param is passed" do
        get :index
        expect(assigns(:change_requests)).to match_array([@cr])
      end

      it 'populate the list with change requests that you need to approve when submitted with approval params' do
        cr_other = FactoryGirl.create(:submitted_change_request)
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

  describe 'release manager access' do
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
