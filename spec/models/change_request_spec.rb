require 'spec_helper'

describe ChangeRequest do
	it "initial state is submitted when first created" do
		change_request = FactoryGirl.create(:change_request)
		expect(change_request.aasm_state).to eq "submitted"
	end

	it "wont be approvable when first created" do
		change_request = FactoryGirl.create(:change_request)
		expect(change_request.approvable?).to eq false
	end

	it "approvers_count will return the count of approvers" do
		change_request = FactoryGirl.create(:change_request)
		expect(change_request.approvers_count).to eq 0
	end
	it "rejects_count will return the count of rejecters" do
		change_request =FactoryGirl.build(:change_request)
		expect(change_request.rejects_count).to eq 0
	end

	it "all_type will return string contain of all types" do
		change_request =FactoryGirl.build(:change_request)
		expect(change_request.all_type).to eq "Install Uninstall, other type"
	end
	 it 'all_category will return string contain of all categories' do
	 	change_request = FactoryGirl.build(:change_request)
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

end
