require 'rails_helper'
require 'slack_notif'
require 'mentioner.rb'

RSpec.describe CommentsController, type:  :controller do
  let(:change_request) {FactoryBot.create(:change_request)}
  let(:cr_comment) {FactoryBot.build(:comment, body: 'comment')}
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    release_manager = FactoryBot.create(:release_manager)
    sign_in release_manager
  end
  describe 'POST #create' do
    context "with valid attributes" do
      it 'saves the new comment in the databse' do
        expect{
          post :create, params: { change_request_id: change_request.id, comment: {body: 'comment'}}
        }.to change(Comment, :count).by(1)
      end

      it 'call slack notification library to notify to the mentionees that they have been mentioned' do
        comment = FactoryBot.build(:comment, body: 'comment @metionee')
        expect_any_instance_of(SlackNotif).to receive(:notify_new_comment).with(an_instance_of(Comment))
        post :create, params: { change_request_id: change_request.id, comment: {body: comment.body} }
      end
    end
    context 'with invalid attributes' do
      it 'doesnt save the new comment in the databse' do
        expect{
          post :create, params: { change_request_id: change_request.id, comment: {body: ''} }
        }.to_not change(Comment, :count)
      end
    end

  end
  describe 'POST #hide_unhide' do
    context 'hide' do
      it 'change the comment into hide state' do
        change_request.comments << cr_comment
        post :hide_unhide, params: { change_request_id: change_request.id, comment_id: cr_comment.id, type: 'hide' }
        expect(Comment.find(cr_comment.id).hide).to eq(true) 
      end
    end
    context 'unhide' do
      it 'change the comment into unhide' do
        change_request.comments << cr_comment
        cr_comment.hide = true
        cr_comment.save
        post :hide_unhide, params: { change_request_id: change_request.id, comment_id: cr_comment.id, type: 'unhide' }
        expect(Comment.find(cr_comment.id).hide).to eq(false) 
      end
    end
  end

end
