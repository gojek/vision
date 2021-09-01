require 'rails_helper'
require 'mentioner'

describe Mentioner do
  let(:user) {FactoryBot.create(:user)}
  let(:change_request) {FactoryBot.create(:change_request, user: user)}
  let(:comment_with_mention) {FactoryBot.create(:comment_with_mention, user: user, change_request: change_request)}

  describe 'Mentioner.extract_handles_from_mentioner' do
    it 'should return array of usernames (email headers) from the comment body' do
      usernames = Mentioner.extract_username(comment_with_mention)
      content = comment_with_mention.body.gsub('@','').split(" ")
      expect(usernames).to match_array(content)
    end
  end

  describe 'Mentioner.find_mentionees_from_username' do
    it 'should return an array of users with the email headers stated in handles' do
      usernames = Mentioner.extract_username(comment_with_mention)
      users = []
      usernames.each do |username|
        users << FactoryBot.create(:user, email: username + "@veritrans.co.id")
      end
      expect(Mentioner.find_mentionees_from_username(usernames)).to match_array(users)
    end
  end

  describe 'Mentioner.process_mentions' do
    it 'should call extract_username method' do
      expect(Mentioner).to receive(:extract_username).with(comment_with_mention).and_call_original
      Mentioner.process_mentions(comment_with_mention)
    end

    it 'should call find_mentionees_from_username' do
      expect(Mentioner).to receive(:find_mentionees_from_username)
      Mentioner.process_mentions(comment_with_mention)
    end
  end

  describe 'Mentioner.mention_prefix' do
    it 'should return @ when called' do
      expect(Mentioner.mention_prefix).to eq "@"
    end
  end

  describe 'Mentioner.username_extract_regex' do
    it 'should return return regex' do
      expect(Mentioner.username_extract_regex).to be_a Regexp
    end
  end
end
