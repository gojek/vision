require 'spec_helper'

describe ChangeRequest, type: :model do
  let (:change_request) {FactoryGirl.create(:change_request)}
  let (:user) {FactoryGirl.create(:approver)}
  let (:user_2) {FactoryGirl.create(:approver)}

  #shoulda matchers test
  it { should belong_to(:user)}
  it { should have_and_belong_to_many(:collaborators) }
  it { should have_and_belong_to_many(:testers) }
  it { should have_and_belong_to_many(:implementers) }
  it { should have_many(:change_request_statuses).dependent(:destroy) }
  it { should have_many(:approvals).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:notifications).dependent(:destroy) }
  
  it "initial state is draft when first created" do
    expect(change_request.aasm_state).to eq "draft"
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

  describe 'approvers_list=' do
    it 'update change request approvers' do
      change_request.approvers_list=([user.id, user_2.id])
      change_request.reload
        expect(change_request.approvals.first.user).to eq user
        expect(change_request.approvals.second.user).to eq user_2
     end
  end
end
