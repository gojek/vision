require 'spec_helper'

describe ChangeRequestsController do

  describe 'requestor access' do
    let(:user) {FactoryGirl.create(:user)}
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET #show' do
      it 'assigns the requested Change Request to @CR' do
        cr = FactoryGirl.create(:change_request)
        get :show, id: cr
        expect(assigns(:change_request)).to eq cr
      end
    end

    describe 'GET #index' do
      it "populate all current user's Change Request if no param is passed" do
        cr = FactoryGirl.create(:change_request, user: user)
        other_cr = FactoryGirl.create(:change_request)
        get :index
        expect(assigns(:change_requests)).to match_array([cr])
      end

      it "populate current user's Change Request based on tag that selected" do
        cr = FactoryGirl.create(:change_request, user: user, tag_list: 'tag')
        other_cr = FactoryGirl.create(:change_request, user: user)
        get :index, tag: 'tag'
        expect(assigns(:change_requests)).to match_array([cr])
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
        cr = FactoryGirl.create(:change_request, user: user)
        get :edit, id: cr
        expect(assigns(:change_request)).to eq cr
      end

      it 'will redirect to Change Request List if current user is the owner of the requested ChangeRequest' do
        cr = FactoryGirl.create(:change_request)
        get :edit, id: cr
        response.should redirect_to change_requests_url
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the new CR in the database' do
          expect{
            approver = FactoryGirl.create(:approver)
            attributes = FactoryGirl.attributes_for(:change_request)
            post :create, change_request: attributes, implementers_list: [approver.id], testers_list: [approver.id] , approvers_list: [approver.name]
          }.to change(ChangeRequest, :count).by(1)
          cr = ChangeRequest.first
          expect(cr.implementers.count).to eq(1)
          expect(cr.testers.count).to eq(1)
        end

        it 'create new approval(s) for the new CR in the database' do
          # CONFIG[:minimum_approval].times do |i|
          #   FactoryGirl.create(:approval)
          # end
          expect{
            approver = FactoryGirl.create(:approver)
            attributes = FactoryGirl.attributes_for(:change_request)
            post :create, change_request: attributes, implementers_list: [approver.id], testers_list: [approver.id] , approvers_list: [approver.name]

          }.to change(Approval, :count).by(1)
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
      before :each do
        @cr = FactoryGirl.create(:change_request, user: user)
      end
      context 'valid attributes' do
        it "change @cr attributes" do
          note = "Note 1"
          approver = FactoryGirl.create(:approver)
          update_attributes = FactoryGirl.attributes_for(:change_request, note: note)
          expect(update_attributes[:note]).to eq(note)
          patch :update , id: @cr.id, change_request: update_attributes, implementers_list: [approver.id], testers_list: [approver.id] , approvers_list: [approver.name]
          @cr.reload
          expect(@cr.note).to eq(note)
        end
      end
      context 'invalid attributes' do
        it "doesnt change the @cr attribute" do
          scope = 'scope'
          patch :update, id: @cr,
          change_request: FactoryGirl.attributes_for(:change_request, scope: scope)
          @cr .reload
          expect(@cr.scope). to_not eq(scope)
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
