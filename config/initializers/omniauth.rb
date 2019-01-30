# 'config/initializers/omniauth.rb'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_API_KEY'], ENV['GOOGLE_API_SECRET'], {
  	access_type: 'offline',
    scope: 'profile,email,https://www.googleapis.com/auth/calendar.events'
  }
end
