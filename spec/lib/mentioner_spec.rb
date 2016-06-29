require 'spec_helper'
require 'mentioner'

describe Mentioner do
  let(:user) {FactoryGirl.create(:user)}
  let(:change_request) {FactoryGirl.create(:change_request, user: user)}
  let(:comment) {FactoryGirl.create(:comment, user: user, change_request: change_request)}
  let(:comment_with_mention) {FactoryGirl.create(:comment_with_mention, user: user, change_request: change_request)}
  describe 'Mentioner.extract_mentioner_content' do
    it 'should return the body of the comment' do
      body = Mentioner.extract_mentioner_content(comment)
      expect(body).to eq(comment.body)
    end
  end

  describe 'Mentioner.extract_handles_from_mentioner' do
    it 'should return array of usernames (email headers) from the comment body' do
      handles = Mentioner.extract_handles_from_mentioner(comment_with_mention)
      content = comment_with_mention.body.gsub('@','').split(" ")
      expect(handles).to match_array(content)
    end
  end

  describe 'Mentioner.find_mentionees_by_handles' do
    it 'should return an array of users with the email headers stated in handles' do
      handles = Mentioner.extract_handles_from_mentioner(comment_with_mention)
      users = []
      handles.each do |handle|
        users << FactoryGirl.create(:user, email: handle + "@veritrans.co.id")
      end
      expect(Mentioner.find_mentionees_by_handles(handles)).to match_array(users)
    end
  end

  describe 'Mentioner.process_mentions' do
    it 'should call extract_handles_from_mentioner method' do
 
    end

    it 'should call find_mentionees_by_handles' do

    end
  end

  describe 'Mentioner.mention_prefix' do
    it 'should return @ when called' do
      expect(Mentioner.mention_prefix).to eq "@"
    end
  end
end
