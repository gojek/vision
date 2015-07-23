require 'spec_helper'

describe ChangeRequest do
	it "initial state is submitted when first created" do
		change_request = FactoryGirl.build(:change_request)
		expect(change_request.aasm_state).to eq "submitted"
	end

	it "wont be approvable when first created" do
		change_request = FactoryGirl.build(:change_request)
		expect(change_request.approvable?).to eq false
	end

	it "approvers_count will return the count of approvers" do
		change_request = FactoryGirl.build(:change_request)
		expect(change_request.approvers_count).to eq 0
	end

end