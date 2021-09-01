require 'rails_helper'
require 'slack_notif'
require 'mentioner.rb'

RSpec.describe AccessRequestCommentsController, type: :controller do
  let(:access_request) {FactoryBot.create(:access_request)}
  let(:ar_comment) {FactoryBot.build(:access_request_comment, body: 'comment')}
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    release_manager = FactoryBot.create(:release_manager)
    sign_in release_manager
  end
  describe 'POST #create' do
    context "with valid attributes" do
      it 'saves the new comment in the databse' do
        expect{
          post :create, params: { access_request_id: access_request.id, access_request_comment: {body: 'comment'} }
        }.to change(AccessRequestComment, :count).by(1)
      end

      it 'call slack notification library to notify to the mentionees that they have been mentioned' do
        comment = FactoryBot.build(:access_request_comment, body: 'comment @metionee')
        expect_any_instance_of(SlackNotif).to receive(:notify_new_ar_comment).with(an_instance_of(AccessRequestComment))
        post :create, params: { access_request_id: access_request.id, access_request_comment: {body: comment.body} }
      end
    end
    context 'with invalid attributes' do
      it 'doesnt save the new comment in the databse' do
        expect{
          post :create, params: { access_request_id: access_request.id, access_request_comment: {body: ''} }
        }.to_not change(AccessRequestComment, :count)
      end
    end

  end
  describe 'POST #hide_unhide' do
    context 'hide' do
      it 'change the comment into hide state' do
        access_request.access_request_comments << ar_comment
        post :hide_unhide, params: { access_request_id: access_request.id, access_request_comment_id: ar_comment.id, type: 'hide' }
        expect(AccessRequestComment.find(ar_comment.id).hide).to eq(true) 
      end
    end
    context 'unhide' do
      it 'change the comment into unhide' do
        access_request.access_request_comments << ar_comment
        ar_comment.hide = true
        ar_comment.save
        post :hide_unhide, params: { access_request_id: access_request.id, access_request_comment_id: ar_comment.id, type: 'unhide' }
        expect(AccessRequestComment.find(ar_comment.id).hide).to eq(false) 
      end
    end
  end

end
