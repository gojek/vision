# 'config/initializers/omniauth.rb'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_API_KEY'], ENV['GOOGLE_API_SECRET'], {
        :prompt => 'consent',
        :access_type => 'offline',
        :scope => 'profile,email,calendar,https://www.google.com/m8/feeds/'
  }
end
