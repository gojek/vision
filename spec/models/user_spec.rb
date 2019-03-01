require 'spec_helper'
require 'slack_helpers.rb'

RSpec.configure do |c|
  c.include SlackHelpers
end

describe User, type: :model do

  let(:user) {FactoryGirl.create(:user)}
  before :all do
    UserList = Struct.new("UserList", :members)
    Profile = Struct.new("Profile", :email)
    UserSlack = Struct.new("UserSlack", :name, :profile)
  end

  #shoulda matchers test
  it { should have_many(:ChangeRequests)}
  it { should have_many(:IncidentReports)}
  it { should have_and_belong_to_many(:collaborate_change_requests) }
  it { should have_and_belong_to_many(:implement_change_requests) }
  it { should have_and_belong_to_many(:test_change_requests) }
  it { should have_many(:Comments)}
  it { should have_many(:Approvals).dependent(:destroy)}
  it { should have_many(:notifications).dependent(:destroy) }


  it "is valid with one of these role : approver, requestor, release_manager" do
    other_user = FactoryGirl.build(:user, role: 'approver')
    another_user = FactoryGirl.build(:user, role: 'release_manager')
    expect(user).to be_valid
    expect(other_user).to be_valid
    expect(another_user).to be_valid
  end

  it "is invalid with role other than approver, requestor, release_manager" do
    user.role = 'jagoan'
    user.valid?
    expect(user.errors[:role].size).to eq(1)
  end

  it "is valid with a veritrans email" do
    expect(user).to be_valid
  end

  it "is invalid without an email address" do
    user.email = nil
    user.valid?
    expect(user.errors[:email].size).to eq(2)
  end

  it "is invalid with a duplicate email address" do
    user.email = 'patrick@veritrans.co.id'
    user.save
    other_user = FactoryGirl.build(:user, email: 'patrick@veritrans.co.id')
    other_user.valid?
    expect(other_user.errors[:email].size).to eq(1)
  end

  it "is invalid with a non-veritrans email" do
    user.email = 'squidward@gmail.com'
    user.valid?
    expect(user.errors[:email].size).to eq(1)
  end

  it "returns true if account is not locked" do
    expect(user.account_active?).to eq true
    expect(user.active_for_authentication?).to eq true
  end
  it "returns false if account is locked" do
    user.locked_at = Time.now
    expect(user.account_active?).to eq false
    expect(user.active_for_authentication?).to eq false
  end

  it "have find_version_author method that will return User who do the version" do
    version = IncidentReportVersion.new(
      item_type: 'IncidentReport',
      item_id: 1,
      event: 'update',
      whodunnit: user.id)
    expect(User.find_version_author(version)).to eq user
  end

  describe 'omniauth authentication user' do
    before :all do
      @slack_username = 'patrick.star'
      user_slack = UserSlack.new(@slack_username, Profile.new('patrick@veritrans.co.id'))
      @users_list = UserList.new([user_slack])
    end

    before :each do
      # Slack::Web::Client.any_instance.stub(users_list: @users_list)
      allow_any_instance_of(Slack::Web::Client).to receive(:users_list).and_return(@users_list)

    end

    it "will find the user based on the auth from omniauth if user already registered" do
      user = FactoryGirl.create(:user)
      auth = {:provider => 'google_oauth2', :uid => user.uid}
      expect(User.from_omniauth(auth)).to eq user
    end

    it "will register new user based on the auth from omniauth if user not registered" do
      user_success_stub
      auth = {:provider => 'google_oauth2', :uid => '123456', :info => {:email => 'patrick@veritrans.co.id', :name => 'patrick star'}}
      user = User.from_omniauth(auth)
      expect(user.provider).to eq auth[:provider]
      expect(user.uid).to eq auth[:uid]
      expect(user.email).to eq auth[:info][:email]
      expect(user.name).to eq auth[:info][:name]
      expect(user.role).to eq 'requestor'
      expect(user.slack_username).to eq @slack_username
      expect(user.is_admin).to eq false
    end

    it "will register the user but slack username is nil because not found" do
      user_failed_stub
      auth = {:provider => 'google_oauth2', :uid => '123456', :info => {:email => 'dummy@dummy.com', :name => 'dummy baby'}}
      user = User.from_omniauth(auth)

      expect(user.slack_username).to be_nil
    end
  end

  it "expired? method will return true if user token has been expired" do
    user = FactoryGirl.create(:user, :expired_at => Time.now - 1.hour)
    expect(user.expired?).to eq true
  end

  it "expired? method will return false if user token has not been expired" do
    user = FactoryGirl.create(:user, :expired_at => Time.now + 1.hour)
    expect(user.expired?).to eq false
  end


  it "fresh_token method will return current token if not expired" do
    expect(user.fresh_token).to eq '123456'
  end

  it "fresh_token method will refresh token and return new token if token expired" do
    user = FactoryGirl.create(:user, :expired_at => Time.now - 1.hour)
    stub_request(:post, 'https://accounts.google.com/o/oauth2/token').with(headers: {'Accept' => '*/*', 'User-Agent' => 'Ruby'}).to_return(
      status: 200,
      body: {
        "access_token": "45678",
        "token_type": "Bearer",
        "expires_in": 3600,
        "id_token": "id"
      }.to_json,
      headers: {}
    )
    expect(user.fresh_token).to eq '45678'
  end

  it "should return list of all approvers if User.approvers is called" do
    approver1 = FactoryGirl.create(:approver)
    approver2 = FactoryGirl.create(:approver)
    user = FactoryGirl.create(:user)
    release_manager = FactoryGirl.create(:release_manager)
    approvers = User.approvers
    approvers.each do |approver|
      expect(approver.role).to eq 'approver'
    end
    expect(approvers).to_not include(user)
    expect(approvers).to_not include(release_manager)
    expect(approvers).to include(approver1)
    expect(approvers).to include(approver2)
  end
  describe "User.have_notifications?" do
    it "should return true if the user have any notifications" do
      user = FactoryGirl.create(:user)
      notification = FactoryGirl.create(:notification, user: user)
      expect(user.have_notifications?).to eq true
    end
    it "should return false if the user does not have any notifications" do
      user = FactoryGirl.create(:user)
      expect(user.have_notifications?).to eq false
    end
  end

  describe "User.is_associated?" do
    it "should return true if the user is associated to a change request" do 
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:change_request, user: user)
      user.reload
      expect(user.is_associated?(cr)).to eq true
    end
    it "should return false if the user is not associated to a change request" do
      user = FactoryGirl.create(:user)
      other_user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:change_request, user: other_user)
      user.reload
      expect(user.is_associated?(cr)).to eq false
    end
  end
end
