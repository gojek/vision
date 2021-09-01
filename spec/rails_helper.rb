# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rails_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'sunspot/rails/spec_helper'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'
require 'sucker_punch/testing/inline'
require 'paper_trail/frameworks/rspec'

WebMock.disable_net_connect!(allow_localhost: true)
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.infer_spec_type_from_file_location!


  config.render_views = true
  config.mock_with :rspec
  config.include FactoryGirl::Syntax::Methods
  config.filter_run_when_matching :focus

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
    stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/***REMOVED***_u8h6tgnhgedrt0c2ognpe7q3q0@group.calendar.google.com/events?sendNotifications=true")
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
