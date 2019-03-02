require 'spec_helper'

describe AccessRequest, type: :model do
	let (:access_request) {FactoryGirl.create(:access_request)}
	let (:draft_access_request) {FactoryGirl.create(:draft_access_request)}
	let (:submitted_access_request) {FactoryGirl.create(:submitted_access_request)}
	let (:closed_access_request) {FactoryGirl.create(:closed_access_request)}
	let (:user) {FactoryGirl.create(:user)}
	let (:admin) {FactoryGirl.create(:admin)}

	#shoulda matchers test
	it { should belong_to(:user)}
	it { should have_many(:approvals).join_table(:access_request_approvals).class_name('AccessRequestApproval').dependent(:destroy) }
	it { should have_many(:statuses).join_table(:access_request_statuses).class_name('AccessRequestStatus').dependent(:destroy) }
	
	it "initial state is draft when first created" do
		expect(access_request.aasm_state).to eq "draft"
	end

  it 'submit record submitted date' do
    Timecop.freeze
    access_request.submit!
    expect(access_request.reload.request_date).to eq Time.current
  end

  describe 'approved / rejected count' do
    let (:access_request_app) {FactoryGirl.create(:access_request, approvals_accept: 2, approvals_alpha: 0)}
    it "approved_count will return the count of approved approvals" do
      expect(access_request.approved_count).to eq 0
      expect(access_request_app.approved_count).to eq 2
    end

    let (:access_request_rej) {FactoryGirl.create(:access_request, approvals_reject: 2,  approvals_alpha: 0)}
    it "rejected_count will return the count of rejected approvals" do
      expect(access_request.rejected_count).to eq 0
      expect(access_request_rej.rejected_count).to eq 2
    end
  end

  describe 'approval_status' do
    it 'returns none for draft' do
      expect(draft_access_request.approval_status).to eq 'none'
    end

    let (:access_request_rej) {FactoryGirl.create(:submitted_access_request, approvals_reject: 1,  approvals_alpha: 0)}
    it 'returns failed for submitted ar with rejected count > 0' do
      expect(access_request_rej.approval_status).to eq 'failed'
    end

    let (:access_request_prog) {FactoryGirl.create(:submitted_access_request, approvals_alpha: 1)}
    it 'returns in progress for submitted ar with approved count < approvals' do
      expect(access_request_prog.approval_status).to eq 'on progress'
    end

    let (:access_request_acc) {FactoryGirl.create(:submitted_access_request, approvals_accept: 1,  approvals_alpha: 0)}
    it 'returns success for submitted ar with approved count = approvals' do
      expect(access_request_acc.approval_status).to eq 'success'
    end
  end

  describe 'editable?' do 
    it 'allow admin to edit' do
      expect(submitted_access_request.editable?(admin)).to eq true
    end

    it 'allow creator to edit' do
      creator = submitted_access_request.user
      expect(submitted_access_request.editable?(creator)).to eq true
    end

    it 'allow collaborators to edit' do
      collaborator = submitted_access_request.collaborators.first
      expect(submitted_access_request.editable?(collaborator)).to eq true
    end
    
    it 'doesn\'t allow approvers to edit' do
      approver = submitted_access_request.approvals.first.user
      expect(submitted_access_request.editable?(approver)).to eq false
    end
    
    let (:random_user) {FactoryGirl.create(:user)}
    it 'doesn\'t allow random user to edit' do
      expect(submitted_access_request.editable?(random_user)).to eq false
    end

    it 'doesn\'t allow edit on terminal state' do
      expect(closed_access_request.editable?(admin)).to eq false
    end
  end

  describe 'closeable?' do
    let (:access_request_clos) {FactoryGirl.create(:submitted_access_request, approvals_accept: 1,  approvals_alpha: 0)}
    it 'closeable if approver count = approval count and approval > 0' do
      expect(access_request_clos.closeable?).to eq true
    end

    let (:access_request_unclos) {FactoryGirl.create(:submitted_access_request, approvals_accept: 1,  approvals_alpha: 1)}
    it 'not closeable if approver count = 0' do
      expect(access_request_unclos.closeable?).to eq false
    end
  end

  describe 'actionable?' do
    it 'allow admin to take action' do
      expect(submitted_access_request.actionable?(admin)).to eq true
    end

    it 'allow creator to take action' do
      creator = submitted_access_request.user
      expect(submitted_access_request.actionable?(creator)).to eq true
    end

    it 'allow associates to take action' do
      collaborator = submitted_access_request.collaborators.first
      approver = submitted_access_request.approvals.first.user
      expect(submitted_access_request.actionable?(collaborator)).to eq true
      expect(submitted_access_request.actionable?(approver)).to eq true
    end
    
    let (:random_user) {FactoryGirl.create(:user)}
    it 'doesn\'t allow random user to take action' do
      expect(submitted_access_request.actionable?(random_user)).to eq false
    end
  end

  describe 'set_approvers' do
    let (:access_request_approv) {FactoryGirl.create(:access_request, approvals_alpha: 1)}
    it 'set access request approvers' do
      access_request_approv.set_approvers=([user.id])
      expect(access_request_approv.approvals.first.user).to eq user
    end
  end

  describe 'set_collaborators' do
    let (:access_request_collab) {FactoryGirl.create(:access_request, collaborators_num: 0)}
    it 'set access request collaborators' do
      access_request_collab.set_collaborators([user.id])
      expect(access_request_collab.reload.collaborators.first).to eq user
    end
  end

end
