# This script started before server is started
# Checks if slack notif configure is already correct

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

notifiction_channels = [
	ENV['SLACK_IR_CHANNEL'],
	ENV['SLACK_CR_CHANNEL']
]

@client = Slack::Web::Client.new
channels_list_names = @client.channels_list.channels.map { |channel| channel.name }

is_valid_config = notifiction_channels.all? { |notif_channel| channels_list_names.include? notif_channel }

if !is_valid_config
	raise 'Slack channels are not found in current registered Slack API.'
end