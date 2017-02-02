source 'https://rubygems.org'
ruby "2.3.0"

# Bundle edge Rails insteadhttps://developers.google.com/oauthplayground: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'unicorn'
gem 'rake', '10.0.0'

# resource-related
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'bootstrap-wysihtml5-rails'
gem 'jquery-rails'
gem 'turbolinks', '~> 2.5.3'
gem 'bootstrap-kaminari-views'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'simple_calendar', '~> 1.1.0'
gem 'fullcalendar-rails'
gem 'momentjs-rails'
gem 'nprogress-rails'
gem 'bootstrap-toggle-rails'

# api-related
gem 'jbuilder', '~> 2.0'

# user-related
gem 'devise'

# file managment
gem 'paper_trail', '~> 4.1'

# oauth
gem 'omniauth-google-oauth2'
gem 'google-api-client', '~> 0.8.2', require: 'google/api_client'
gem 'httpclient'

# server-related
# gem 'dotenv' # to allow loading environment variable locally by file
gem 'foreman', '0.82' # to load environment variable, foreman start/foreman rails c
gem 'thor', '0.19.1'

# data representation
gem 'ransack'
gem 'kaminari'
gem 'to_xls-rails'
gem 'diffy'
gem 'cocoon'
gem 'acts-as-taggable-on'
gem 'aasm'
gem 'figaro'
gem 'html_truncator', '~>0.2'
gem 'unread'
gem 'data-confirm-modal'
gem 'jquery-atwho-rails'
gem 'exception_notification'
gem 'pry-byebug'
gem 'omniauth'
gem 'tinymce-rails', '4.3.8'
gem 'comma', '~> 3.2.1'

# xml parser
gem 'nokogiri'

# database
gem 'pg'

# coloring std out
gem 'colorize'

#slack notification
gem 'slack-ruby-client'


# full-text search
gem 'sunspot_rails'
gem 'sunspot_solr'

group :production do
  gem 'rails_12factor'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # mail catcher is being used for email in development
  # based on the https://mailcatcher.me/
  # it is stated that "Please don't put mailcatcher into your Gemfile. 
  # It will conflict with your applications gems at some point."
  # Instead, simply run gem install mailcatcher then mailcatcher to get started.

end
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'faker'
	gem 'cucumber-rails', require: false
  gem 'byebug'
  gem 'rspec-rails', '~> 2.14'
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'guard-rspec', '4.2.0', require: false
  gem 'sunspot_test'
  # Access an IRB console on exception pages or by using <%= console %> in views
  #

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver', "~> 2.53.1"
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'webmock'

  gem 'timecop'
end
