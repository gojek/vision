require 'spec_helper'

describe User do
	it "is valid with one of these role : approver, requestor, release_manager" do
		user = FactoryGirl.build(:user)
		other_user = FactoryGirl.build(:user, role: 'approver')
		another_user = FactoryGirl.build(:user, role: 'release_manager')
		expect(user).to be_valid
		expect(other_user).to be_valid
		expect(another_user).to be_valid
	end
	it "is invalid with role other than approver, requestor, release_manager" do
		user = FactoryGirl.build(:user, role: 'jagoan')
		expect(user).to have(1).errors_on(:role)
	end
	it "is valid with a veritrans email" do 
		user = FactoryGirl.build(:user)
		expect(user).to be_valid
	end
	it "is invalid without an email address" do
		user = FactoryGirl.build(:user, email: nil)
		expect(user).to have(2).errors_on(:email)
	end
	it "is invalid with a duplicate email address" do
		user = FactoryGirl.create(:user)
		other_user = FactoryGirl.build(:user)
		expect(other_user).to have(1).errors_on(:email)
	end
	it "is invalid with a non-veritrans email" do
		user = FactoryGirl.build(:user, email: 'squidward@gmail.com')
		expect(user).to have(1).errors_on(:email)
	end
	it "returns true if account is not locked" do
		user = FactoryGirl.create(:user)
		expect(user.account_active?).to eq true
		expect(user.active_for_authentication?).to eq true
	end
	it "returns false if account is locked" do
		user = FactoryGirl.create(:user, locked_at: Time.now)
		expect(user.account_active?).to eq false
		expect(user.active_for_authentication?).to eq false
	end

	it "have find_version_author method that will return User who do the version" do
		user = FactoryGirl.create(:user)
		version = IncidentReportVersion.new(
			item_type: 'IncidentReport',
			item_id: 1,
			event: 'update',
			whodunnit: 1)
		expect(User.find_version_author(version)).to eq user
	end

	it "will find the user based on the auth from omniauth if user already registered" do
		user = FactoryGirl.create(:user)
		auth = {:provider => 'google_oauth2', :uid => '123456'}
		expect(User.from_omniauth(auth)).to eq user
	end

	it "will register new user based on the auth from omniauth if user not registered" do
		auth = {:provider => 'google_oauth2', :uid => '123456', :info => {:email => 'patrick@veritrans.co.id', :name => 'patrick star'}}
		user = User.from_omniauth(auth)
		expect(user.provider).to eq auth[:provider]
		expect(user.uid).to eq auth[:uid]
		expect(user.email).to eq auth[:info][:email]
		expect(user.name).to eq auth[:info][:name]
		expect(user.role).to eq 'requestor'
		expect(user.is_admin).to eq false
	end
end