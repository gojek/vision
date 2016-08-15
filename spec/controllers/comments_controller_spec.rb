require 'spec_helper'
require 'slack_notif'
require 'mentioner.rb'

describe CommentsController do
	let(:change_request) {FactoryGirl.create(:change_request)}
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user]
		release_manager = FactoryGirl.create(:release_manager)
		sign_in release_manager
	end
	describe 'POST #create' do
		context "with valid attributes" do
			it 'saves the new comment in the databse' do
				expect{
					post :create, change_request_id: change_request.id, comment: {body: 'comment'}
				}.to change(Comment, :count).by(1)
			end

			it 'call slack notification library to notify to the mentionees that they have been mentioned' do
				comment = FactoryGirl.build(:comment, body: 'comment @metionee')
				expect_any_instance_of(SlackNotif).to receive(:notify_new_comment).with(an_instance_of(Comment))
				post :create, change_request_id: change_request.id, comment: {body: comment.body}
			end
		end
		context 'with invalid attributes' do
			it 'doesnt save the new comment in the databse' do
				expect{
					post :create, change_request_id: change_request.id, comment: {body: ''}
				}.to_not change(Comment, :count)
			end
		end

	end

end
