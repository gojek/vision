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

    end

    describe 'GET #edit' do

    end

    describe 'GET #deleted' do

    end

    describe 'PUT #approve' do

    end

    describe 'PUT #reject' do

    end
  end
end