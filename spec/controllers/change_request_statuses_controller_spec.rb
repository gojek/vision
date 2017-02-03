require 'spec_helper'

describe ChangeRequestStatusesController, type: :controller do
	let(:user) {FactoryGirl.create(:user)}
	before :each do
		controller.request.env['devise.mapping'] = Devise.mappings[:user]
		release_manager = FactoryGirl.create(:release_manager)
		sign_in release_manager
	end

  describe 'POST #schedule' do
		let(:cr){FactoryGirl.create(:submitted_change_request, user: user)}
    it 'will able to change the state to scheduled if current state is submitted and has reached approval limit' do
			count_approvals = cr.approvals.count
      @approvals =  cr.approvals
      @approvals.each do |approval|
        approval.update(approve: true)
      end
			cr.reload
      expect(cr.approvers_count).to eq count_approvals
      post :schedule, id: cr, change_request_status: {:status => 'scheduled'}
      cr.reload
      expect(cr.aasm_state).to eq 'scheduled'
    end

    it 'wont able to change the state to scheduled if hasnt reached approval limit' do
      post :schedule, id: cr, change_request_status: {:status => 'scheduled'}
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end
  end

  describe 'POST #deploy' do
    it 'will able to change the state to deployed if current state is scheduled' do
      cr = FactoryGirl.create(:scheduled_change_request,user: user)
      post :deploy , id: cr, change_request_status:{:status => 'deployed'}
      cr.reload
      expect(cr.aasm_state).to eq 'deployed'
    end
  end

  describe 'POST #rollback' do
      it 'will able to change the state to rollback if current state is scheduled and reason is filled' do
      cr = FactoryGirl.create(:scheduled_change_request, user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked',:reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rollbacked'
    end
    it 'will able to change the state to rollback if current state is deployed and reason is filled' do
      cr = FactoryGirl.create(:deployed_change_request,user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rollbacked'
    end
    it 'wont able to change  the state to rollbacked if current state rejected' do
      cr = FactoryGirl.create(:rejected_change_request,user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rejected'
    end
    it 'wont able to change the state to rollbacked if reason is not filled' do
      cr = FactoryGirl.create(:deployed_change_request,user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked'}
      cr.reload
      expect(cr.aasm_state).to eq 'deployed'
    end

  end

  describe 'POST #cancel' do
		let(:cr){FactoryGirl.create(:scheduled_change_request, user: user)}
    it 'will able to change the state to cancelled if current state is scheduled' do
      post :cancel , id: cr, change_request_status:{:status => 'cancelled', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'cancelled'
    end
    it 'wont able to change the state to cancelled if reason is not filled' do
      post :cancel , id: cr, change_request_status:{:status => 'cancelled'}
      cr.reload
      expect(cr.aasm_state).to eq 'scheduled'
    end
  end

  describe 'POST #close' do
		let(:cr){FactoryGirl.create(:submitted_change_request, user: user)}
    it 'will able to change the state to close if current state is scheduled' do
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
		it 'will able to change the state to close if current state is submitted' do
			cr.update(aasm_state: 'submitted')
			post :close , id: cr, change_request_status:{:status => 'closed'}
			cr.reload
			expect(cr.aasm_state).to eq 'closed'
    end
    it 'will able to change the state to close if current state is rejected' do
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is deployed' do
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is rollbacked' do
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is cancelled' do
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
  end

  describe 'POST #final_reject' do
		let(:cr){FactoryGirl.create(:submitted_change_request, aasm_state: 'submitted',user: user)}
    it 'will able to change the state to rejected if current state is submitted' do
      post :final_reject , id: cr, change_request_status:{:status => 'rejected', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rejected'
    end
    it 'wont able to change the state to rejected if reason is not filled' do
      post :final_reject , id: cr, change_request_status:{:status => 'rejected'}
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end
  end

  describe 'POST #submit' do
     it 'will able to change the state to submitted if current state is cancelled' do
      cr = FactoryGirl.create(:cancelled_change_request,user: user)
      post :submit , id: cr, change_request_status:{:status => 'submitted'}
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end

  end

end
