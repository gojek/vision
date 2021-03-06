# frozen_string_literal: true

class SlackClient
  attr_accessor :client

  def initialize
    @client = Slack::Web::Client.new
  end

  def message_users(users, message, attachment)
    users.each do |user|
      try_send(user, message, [attachment])
    end
  end

  def message_channel(channel, message, attachment)
    @client.chat_postMessage(channel: "##{channel}", text: message, attachments: [attachment])
  end

  def reassign_slack_username(user)
    user.slack_username = get_slack_username(user)
    user.save
  end

  private

  def get_slack_username(user)
    user = @client.users_lookupByEmail('email': user.email)
    user.user.name
  rescue StandardError
    nil
  end

  def try_send(user, message, attachments)
    tries ||= 2
    @client.chat_postMessage(channel: "@#{user.slack_username}", text: message, attachments: attachments)
  rescue Slack::Web::Api::Error => e
    return if e.message != 'channel_not_found'
    reassign_slack_username(user)
    retry unless (tries -= 1).zero?
  end
end
