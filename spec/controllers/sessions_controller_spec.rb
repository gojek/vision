require 'spec_helper'
require 'helpers'


RSpec.configure do |c|
  c.include Helpers
end

describe SessionController, type: :controller do
  
  before :each do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  describe 'rejected user login to vision' do
    
  end
end
