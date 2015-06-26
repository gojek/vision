# 'config/initializers/omniauth.rb'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '772021837446-vnbketkbvppb2o38lrnrjtdt4v2cfi2g.apps.googleusercontent.com', 'dxIshXuB0zqC2enaPZZx4ooL', {
  	:prompt => '',
  	:hd => 'veritrans.co.id'
  }
end