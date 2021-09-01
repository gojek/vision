# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails insteadhttps://developers.google.com/oauthplayground: gem 'rails', github: 'rails/rails'
gem 'puma', '~> 3.12.0'
gem 'rails', '5.2.6'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'bootsnap', require: false

# resource-related
gem 'bootstrap-kaminari-views'
gem 'bootstrap-toggle-rails'
gem 'bootstrap-wysihtml5-rails'
gem 'coffee-rails', '>= 4.1.0'
gem 'fullcalendar-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'momentjs-rails'
gem 'nprogress-rails'
gem 'sass-rails', '~> 5.0'
gem 'simple_calendar', '~> 1.1.0'
gem 'turbolinks', '~> 2.5.3'
gem 'uglifier', '>= 1.3.0'

# api-related
gem 'jbuilder', '~> 2.0'

# user-related
gem 'devise'

# file managment
gem 'paper_trail'
gem 'sucker_punch', '~> 2.0'

# oauth
gem 'google-api-client', '~> 0.20.0'
gem 'httpclient'
gem 'omniauth-google-oauth2'

# server-related
# gem 'dotenv' # to allow loading environment variable locally by file
gem 'foreman', '0.82' # to load environment variable, foreman start/foreman rails c
gem 'thor', '0.19.1'

# data representation
gem 'aasm'
gem 'acts-as-taggable-on'
gem 'cocoon'
gem 'comma', '~> 3.2.1'
gem 'data-confirm-modal'
gem 'diffy'
gem 'exception_notification'
gem 'figaro'
gem 'groupdate'
gem 'html_truncator', '~>0.2'
gem 'jquery-atwho-rails'
gem 'kaminari'
gem 'omniauth'
gem 'pry-byebug'
gem 'ransack'
gem 'tinymce-rails', '4.3.8'
gem 'to_xls-rails'
gem 'unread'

# xml parser
gem 'nokogiri'

# database
gem 'pg', '~> 0.19'

# coloring std out
gem 'colorize'

# slack notification
gem 'slack-notifier'
gem 'slack-ruby-client', '~> 0.13.1'

# jira
gem 'jira-ruby', require: 'jira-ruby'

# full-text search
gem 'sunspot_rails'
gem 'sunspot_solr'

# sanitizer
gem 'sanitize'

group :production do
  gem 'rails_12factor'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '~> 2.0'

  # mail catcher is being used for email in development
  # based on the https://mailcatcher.me/
  # it is stated that "Please don't put mailcatcher into your Gemfile.
  # It will conflict with your applications gems at some point."
  # Instead, simply run gem install mailcatcher then mailcatcher to get started.
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'cucumber-rails', require: false
  gem 'dotenv-rails'
  gem 'factory_bot_rails', '4.8.2'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '3.7.2'
  gem 'sunspot_test'
  # Access an IRB console on exception pages or by using <%= console %> in views
  #

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'rubocop', require: false
  gem 'rubycritic', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'dotenv', '~> 2.7'
  gem 'launchy'
  gem 'selenium-webdriver', '~> 2.53.1'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'webmock'
end
