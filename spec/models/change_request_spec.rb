require 'spec_helper'

describe ChangeRequest do
	let (:change_request) {FactoryGirl.create(:change_request)}
	let (:user) {FactoryGirl.create(:approver)}

	it "initial state is submitted when first created" do
		expect(change_request.aasm_state).to eq "submitted"
	end

	it "wont be approvable when first created" do
		expect(change_request.approvable?).to eq false
	end

	it "approvers_count will return the count of approvers" do
		expect(change_request.approvers_count).to eq 0
	end
	it "rejects_count will return the count of rejecters" do
		expect(change_request.rejects_count).to eq 0
	end

	it "all_type will return string contain of all types" do
		expect(change_request.all_type).to eq "Install Uninstall, other type"
	end
	 it 'all_category will return string contain of all categories' do
	 	expect(change_request.all_category).to eq "Application, Server"
	 end

	 it "at_least_one_category will return error if all categories not selected" do
	 	change_request = FactoryGirl.build(:change_request, category_server: nil, category_application:nil)
	 	expect(change_request.at_least_one_category).to match_array(["Please choose at least one category."])
	 end
	 it "at_least_one_type will return error if all types not selected" do
	 	change_request = FactoryGirl.build(:change_request, type_install_uninstall:nil, type_other:nil)
	 	expect(change_request.at_least_one_type).to match_array(["Please choose at least one type."])
	 end

	 describe 'set_approvers' do
	 	it 'set change request approvers' do
			change_request.set_approvers([user.id])
			expect(change_request.approvals.first.user).to eq user
	 	end
	 end

	 describe 'set_implementers' do
	 	it 'set change request implementers' do
			change_request.set_implementers([user.id])
			expect(change_request.implementers.first).to eq user
	 	end
	 end

	 describe 'set_testers' do
	 	it 'set change request testers' do
			change_request.set_testers([user.id])
			expect(change_request.testers.first).to eq user
	 	end
	 end

	 describe 'set_collaborators' do
	 	it 'set change request collaborators' do
			change_request.set_collaborators([user.id])
			expect(change_request.collaborators.first).to eq user
	 	end
	 end

end
