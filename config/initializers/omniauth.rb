# 'config/initializers/omniauth.rb'
Rails.application.config.middleware.use OmniAuth::Builder do
  API_KEYS = YAML::load_file("#{Rails.root}/config/api_key.yml")[Rails.env]
  provider :google_oauth2, API_KEYS['google']['api_key'], API_KEYS['google']['api_secret'], {
  	:prompt => '',
  	:hd => 'veritrans.co.id'
  }
end