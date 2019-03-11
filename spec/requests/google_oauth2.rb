require 'spec_helper'
require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

describe "Google oauth2 request for logn", type: :request do
  let(:user) {FactoryGirl.create(:user)}
  let(:waiting) {FactoryGirl.create(:waiting_user)}
  let(:reject) {FactoryGirl.create(:rejected_user)}
  let(:admin) {FactoryGirl.create(:admin)}
  let(:pending_user) {FactoryGirl.create(:pending_user)}

    
  describe 'user try to sign in' do
    it 'is sign_in rejected user' do
      google_oauth_login_mock(reject, request)
      get "/users/auth/google_oauth2"
    end

    it 'is sign_in pending user' do
      expect(response).to redirect_to register_path
    end

    it 'is sign_in waiting approval user' do
      sign_in user
      expect(response).to redirect_to signin_path
    end

    it 'is sign_in approved user' do
      sign_in waiting
      expect(response).to redirect_to signin_path
    end
  end
end
