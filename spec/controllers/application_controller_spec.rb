require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  context 'user access' do
    let(:user) {FactoryBot.create(:user)}
    let(:waiting_user) {FactoryBot.create(:waiting_user)}
    let(:rejected_user) {FactoryBot.create(:rejected_user)}
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'is sign_in rejected user' do
      sign_in rejected_user
      expect(response.status).to eq 200
    end

    it 'is sign_in waiting user' do
      sign_in waiting_user
      expect(response.status).to eq 200
    end

    it 'is sign_in approved user' do
      sign_in user
      expect(response.status).to eq 200
    end

  end
end
