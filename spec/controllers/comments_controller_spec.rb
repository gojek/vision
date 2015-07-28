require 'spec_helper'

describe CommentsController do
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user]
		release_manager = FactoryGirl.create(:release_manager)
		sign_in release_manager
	end
	describe 'POST #create' do
		context "with valid attributes" do
			before :each do
				@cr = FactoryGirl.create(:change_request)
			end
			it 'saves the new comment in the databse' do
				expect{
					post :create, change_request_id: @cr.id, comment: {body: 'comment'}
				}.to change(Comment, :count).by(1)
			end
		end
		context 'with invalid attributes' do
			before :each do
				@cr = FactoryGirl.create(:change_request)
			end
			it 'doesnt save the new comment in the databse' do
				expect{
					post :create, change_request_id: @cr.id, comment: {body: ''}
				}.to_not change(Comment, :count)
			end
		end

	end

end