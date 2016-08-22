require 'slack_attachment_builder.rb'
require 'mentioner.rb'

class SlackNotif
  include Rails.application.routes.url_helpers

  def initialize
    @client = Slack::Web::Client.new
    @attachment_builder = SlackAttachmentBuilder.new
  end

  def notify_new_cr(change_request)
    attachment = @attachment_builder.generate_change_request_attachment(change_request)
    link = change_request_url(change_request)
    approvers = change_request.approvals.collect{|approval| approval.user}
    approver_message = "New <#{link}|change request> needs your approvals"
    message_users(approvers, approver_message, attachment)
    associated_users = change_request.associated_users
    general_message = "New <#{link}|change request> has been created"
    message_users(associated_users - approvers, general_message, attachment)
    message_channel('cab', general_message, attachment)
  end

  def notify_update_cr(change_request)
    attachment = @attachment_builder.generate_change_request_attachment(change_request)
    link = change_request_url(change_request)
    approvers = change_request.approvals.collect{|approval| approval.user}
    approver_message = "Modified <#{link}|change request> needs your approvals"
    message_users(approvers, approver_message, attachment)
    associated_users = change_request.associated_users
    general_message = "<#{link}|Change request> has been modified"
    message_users(associated_users - approvers, general_message, attachment)
    message_channel('cab', general_message, attachment)
  end

  def notify_new_comment(comment)
    attachment = @attachment_builder.generate_comment_attachment(comment)
    link = change_request_url(comment.change_request)
    mentionees =  Mentioner.process_mentions(comment)
    if !mentionees.empty?
      mentioned_message = "You are mentioned in #{comment.user.name} comment's on a <#{link}|change request>"
      message_users(mentionees, mentioned_message, attachment)
    end
    associated_users = comment.change_request.associated_users - [comment.user]
    general_message = "A new comment from #{comment.user.name} on a <#{link}|change request>"
    message_users(associated_users - mentionees, general_message, attachment)
  end

  private
  def message_users(users, message, attachment)
    users.each do |user|
      next if user.slack_username.blank?
      @client.chat_postMessage(channel: "@#{user.slack_username}", text: message, attachments: [attachment])
    end
  end

  def message_channel(channel, message, attachment)
    @client.chat_postMessage(channel: "##{channel}", text: message, attachments: [attachment])
  end

end
