require 'spec_helper'

describe User do
	it "is valid with one of these role : approver, requestor, release_manager" do
		user = User.new(
			email: 'patrick@veritrans.co.id',
			role: 'approver')
		other_user = User.new(
			email: 'patrick@veritrans.co.id',
			role: 'requestor')
		another_user = User.new(
			email: 'patrick@veritrans.co.id',
			role: 'release_manager')
		expect(user).to be_valid
		expect(other_user).to be_valid
		expect(another_user).to be_valid
	end
	it "is invalid with role other than approver, requestor, release_manager" do
		user = User.new(
			email: 'patrick@veritrans.co.id',
			role: 'jagoan')
		expect(user).to have(1).errors_on(:role)
	end
	it "is valid with a veritrans email" do 
		user = User.new(
			email: 'patrick@veritrans.co.id',
			role: 'requestor')
		expect(user).to be_valid
	end
	it "is invalid without an email address" do
		user = User.new(
			email: nil,
			role: 'requestor')
		expect(user).to have(2).errors_on(:email)
	end
	it "is invalid with a duplicate email address" do
		User.create(
			email: 'patrick@veritrans.co.id',
			role: 'requestor')
		other_user = User.new(
			email: 'patrick@veritrans.co.id',
			role: 'requestor')
		expect(other_user).to have(1).errors_on(:email)
	end
	it "is invalid with a non-veritrans email" do
		user = User.new(
			email: 'squidward@gmail.com',
			role: 'requestor')
		expect(user).to have(1).errors_on(:email)
	end
	it "returns true if account is not locked" do
		user = User.create(
			email: 'patrick@veritrans.co.id',
			role: 'requestor',
			locked_at: nil)
		expect(user.account_active?).to eq true
		expect(user.active_for_authentication?).to eq true
	end
	it "returns false if account is locked" do
		user = User.create(
			email: 'patrick@veritrans.co.id',
			role: 'requestor',
			locked_at: Time.now)
		expect(user.account_active?).to eq false
		expect(user.active_for_authentication?).to eq false
	end
end