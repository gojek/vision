# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end