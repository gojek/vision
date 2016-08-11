# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'capybara-screenshot/rspec'
require 'simplecov'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'webmock/rspec'
require 'sunspot/rails/spec_helper'

WebMock.disable_net_connect!(allow_localhost: true)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.before(:each) do
    ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)

    cal_response_json = File.read(File.expand_path("../webmocks/calendar_response.json", __FILE__))
    cal_add_response_json = File.read(File.expand_path("../webmocks/add_calendar.json", __FILE__))
    get_cal_response_json = File.read(File.expand_path("../webmocks/get_calendar.json", __FILE__))
    contact_response_xml = File.read(File.expand_path("../webmocks/contact_response.xml", __FILE__))

    # get calendar
    stub_request(:get, "https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest")
      .with(headers: {'Accept'=>'*/*'})
      .to_return(status: 200, body: cal_response_json, headers: {
        'Content-location' => 'https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest',
        'Server' => 'GSE',
        'Content-type' => 'application/json',
        'charset' => 'UTF-8'
    })

    # add to calendar
    stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/primary/events?sendNotifications=true")
      .with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip',
                      'Authorization'=>'Bearer 123456', 'Cache-Control'=>'no-store',
                      'Content-Type'=>'application/json'})
      .to_return(status: 200, body: cal_add_response_json, headers: {
        'Server' => 'GSE',
        'Content-type' => 'application/json'
    })

    # get contacts
    stub_request(:get, "https://www.google.com/m8/feeds/contacts/default/full/").
      with(:headers => {'Accept'=>'*/*', 'Authorization'=>'Bearer 123456',
                        'Gdata-Version'=>'3.0',
                        'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.2.2 (2015-04-13))'})
      .to_return(:status => 200, :body => contact_response_xml, :headers => {})

    # delete calendar
    stub_request(:delete, "https://www.googleapis.com/calendar/v3/calendars/primary/events/?sendNotifications=true").
      with(:headers => {'Accept'=>'*/*', 'Authorization'=>'Bearer 123456'})
      .to_return(:status => 200, :body => "", :headers => {})

    # get/read calendar
    stub_request(:get, "https://www.googleapis.com/calendar/v3/calendars/primary/events/")
      .with(headers: {'Accept'=>'*/*', 'Authorization'=>'Bearer 123456'})
      .to_return(status: 200, body: get_cal_response_json, headers: {
        'Server' => 'GSE',
        'Content-type' => 'application/json'
    })

    # put calendar
    stub_request(:put, "https://www.googleapis.com/calendar/v3/calendars/primary/events/?sendNotifications=true")
      .with(headers: {'Accept'=>'*/*', 'Authorization'=>'Bearer 123456'})
      .to_return(status: 200, body: "", headers: {})
  end

  config.after(:each) do
    ::Sunspot.session = ::Sunspot.session.original_session
  end

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Devise::TestHelpers, :type => :controller

end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
