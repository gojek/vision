require 'rails_helper'

RSpec.describe ChangeRequestStatusesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    
    release_manager = FactoryBot.create(:release_manager)
    sign_in release_manager
  end

  describe 'POST #deploy' do
    let(:cr) { FactoryBot.create(:change_request, user: user, aasm_state: 'submitted') }

    it 'will able to change the state to deployed if current state is scheduled' do
      cr.approvals.update_all(approve: true)
      post :deploy , params: { id: cr, change_request_status:{:status => 'deployed'}}
      cr.reload
      expect(cr.aasm_state).to eq 'deployed'
    end
  end

  describe 'POST #rollback' do
    it 'will able to change the state to rollback if current state is scheduled and reason is filled' do
      cr = FactoryBot.create(:scheduled_change_request, user: user)
      post :rollback , params: { id: cr, change_request_status: {:status => 'rollbacked', :reason =>'reason'} }
      cr.reload
      expect(cr.aasm_state).to eq 'rollbacked'
    end

    it 'will able to change the state to rollback if current state is deployed and reason is filled' do
      cr = FactoryBot.create(:deployed_change_request,user: user)
      post :rollback , params: { id: cr, change_request_status:{:status => 'rollbacked', :reason =>'reason'}}
      cr.reload
      expect(cr.aasm_state).to eq 'rollbacked'
    end

    it 'wont able to change the state to rollbacked if reason is not filled' do
      cr = FactoryBot.create(:deployed_change_request,user: user)
      post :rollback , params: { id: cr, change_request_status:{:status => 'rollbacked'}}
      cr.reload
      expect(cr.aasm_state).to eq 'deployed'
    end

  end

  describe 'POST #cancel' do
    let(:cr) { FactoryBot.create(:change_request, user: user, aasm_state: 'submitted') }

    it 'able to change the state to cancelled' do
      post :cancel , params: {id: cr, change_request_status:{:status => 'cancelled', reason: 'reason'}}
      cr.reload
      expect(cr.aasm_state).to eq 'cancelled'
    end
  end

  describe 'POST #close' do
    let(:cr) { FactoryBot.create(:change_request, user: user, aasm_state: 'deployed') }
    it 'will able to change the state to succeeded ' do
      post :close , params: { id: cr, change_request_status:{:status => 'closed'}}
      cr.reload
      expect(cr.aasm_state).to eq 'succeeded'
    end
  end

  describe 'POST #submit' do
     it 'will able to change the state to submitted if current state is cancelled' do
      cr = FactoryBot.create(:change_request, user: user, aasm_state: 'draft')
      post :submit , params: { id: cr, change_request_status:{:status => 'submitted'} }
      cr.reload
      expect(cr.aasm_state).to eq 'submitted'
    end

  end

end
