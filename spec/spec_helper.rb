# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'capybara-screenshot/rspec'
require 'simplecov'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= 'test'
ENV["APPROVER_EMAIL"] ||= 'ika.​muiz@midtrans.com'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'sunspot/rails/spec_helper'
require 'capybara/rspec'  
require 'capybara/rails'
require 'sucker_punch/testing/inline'

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

    stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars//events?sendNotifications=true")
      .to_return(status: 200, body: cal_add_response_json, headers: {
        'Server' => 'GSE',
        'Content-type' => 'application/json'
      })
    # Event calender
    stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/veritrans.co.id_u8h6tgnhgedrt0c2ognpe7q3q0@group.calendar.google.com/events?sendNotifications=true")
      .to_return(status: 403, body: JSON.dump({
        "error":{
          "errors":[{
            "domain":"calendar",
            "reason":"requiredAccessLevel",
            "message":"You need to have writer access to this calendar."}],
            "code":403,"message":"You need to have writer access to this calendar."}}))

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

    # slack notification
    stub_request(:post, "https://slack.com/api/chat.postMessage")
      .to_return(status: 200, body: '{"ok": true}', headers: {})

    stub_request(:post, "https://slack.com/api/users.list")
      .to_return(status: 200, body: '{"ok": true}', headers: {})

    # clear action mailer
    ActionMailer::Base.deliveries = []

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

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.infer_spec_type_from_file_location!

end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def login_as(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:google_oauth2, {
    uid: user.uid,
    credentials: {
      token: "token",
      refresh_token: "refresh_token",
      expired_at: Time.now + 7.days
    }
  })
  visit("/users/auth/google_oauth2")
  OmniAuth.config.test_mode = false
end
