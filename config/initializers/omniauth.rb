# 'config/initializers/omniauth.rb'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '***REMOVED***', '***REMOVED***', {
  	:prompt => '',
  	:hd => '***REMOVED***'
  }
end