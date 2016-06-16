require 'spec_helper'

describe ChangeRequestStatusesController do
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user]
		release_manager = FactoryGirl.create(:release_manager)
		sign_in release_manager
	end

  describe 'POST #schedule' do
    it 'will able to change the state to scheduled if current state is submitted and has reached approval limit' do
      #cr.stub(:approvable?).and_return(true)
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:submitted_change_request, user: user)
      CONFIG[:minimum_approval].times do |i|
        FactoryGirl.create(:approval)
      end
      @approvers = User.where(role: "approver")
      @approvers.each do |approver|
        @approval = Approval.create(user_id: approver.id, change_request_id: cr.id, approve: true)
      end
      expect(cr.approvers_count).to eq CONFIG[:minimum_approval]
      post :schedule, id: cr, change_request_status: {:status => 'scheduled'}
      cr.reload
      expect(cr.aasm_state).to eq 'scheduled'
    end

    it 'wont able to change the state to scheduled if hasnt reached approval limit' do
      cr = FactoryGirl.create(:submitted_change_request)
      post :schedule, id: cr, change_request_status: {:status => 'scheduled'}
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end
  end

  describe 'POST #deploy' do
    it 'will able to change the state to deployed if current state is scheduled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:scheduled_change_request,user: user)
      post :deploy , id: cr, change_request_status:{:status => 'deployed'}
      cr.reload
      expect(cr.aasm_state).to eq 'deployed'
    end
  end

  describe 'POST #rollback' do
      it 'will able to change the state to rollback if current state is scheduled and reason is filled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:scheduled_change_request, user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked',:reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rollbacked'
    end
    it 'will able to change the state to rollback if current state is deployed and reason is filled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:deployed_change_request,user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rollbacked'
    end
    it 'wont able to change  the state to rollbacked if current state rejected' do
       user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:rejected_change_request,user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rejected'
    end
    it 'wont able to change the state to rollbacked if reason is not filled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:deployed_change_request,user: user)
      post :rollback , id: cr, change_request_status:{:status => 'rollbacked'}
      cr.reload
      expect(cr.aasm_state).to eq 'deployed'
    end

  end

  describe 'POST #cancel' do
    it 'will able to change the state to cancelled if current state is scheduled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:scheduled_change_request,user: user)
      post :cancel , id: cr, change_request_status:{:status => 'cancelled', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'cancelled'
    end
    it 'wont able to change the state to cancelled if reason is not filled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:scheduled_change_request,user: user)
      post :cancel , id: cr, change_request_status:{:status => 'cancelled'}
      cr.reload
      expect(cr.aasm_state).to eq 'scheduled'
    end
  end

  describe 'POST #close' do
    it 'will able to change the state to close if current state is scheduled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:scheduled_change_request,user: user)
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is submitted' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:submitted_change_request, aasm_state: 'submitted',user: user)
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is rejected' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:rejected_change_request, user: user)
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is deployed' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:deployed_change_request ,user: user)
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is rollbacked' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:rollbacked_change_request, user: user)
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
     it 'will able to change the state to close if current state is cancelled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:cancelled_change_request, user: user)
      post :close , id: cr, change_request_status:{:status => 'closed'}
      cr.reload
      expect(cr.aasm_state).to eq 'closed'
    end
  end

  describe 'POST #final_reject' do
    it 'will able to change the state to rejected if current state is submitted' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:submitted_change_request, aasm_state: 'submitted',user: user)
      post :final_reject , id: cr, change_request_status:{:status => 'rejected', :reason =>'reason'}
      cr.reload
      expect(cr.aasm_state).to eq 'rejected'
    end
    it 'wont able to change the state to rejected if reason is not filled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:submitted_change_request, aasm_state: 'submitted',user: user)
      post :final_reject , id: cr, change_request_status:{:status => 'rejected'}
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end
  end

  describe 'POST #submit' do
     it 'will able to change the state to submitted if current state is cancelled' do
      user = FactoryGirl.create(:user)
      cr = FactoryGirl.create(:cancelled_change_request,user: user)
      post :submit , id: cr, change_request_status:{:status => 'submitted'}
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end

  end

end
