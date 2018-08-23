require 'slack_attachment_builder.rb'
require 'mentioner.rb'

class SlackNotif
  include Rails.application.routes.url_helpers

  def initialize
    @client = Slack::Web::Client.new
    @attachment_builder = SlackAttachmentBuilder.new
    @members = @client.users_list.members
  end

  def notify_new_cr(change_request)
    notify_change_cr(change_request, 'created')
  end

  def notify_new_ar(access_request)
    notify_change_ar(access_request, 'created')
  end

  def notify_update_cr(change_request)
    notify_change_cr(change_request, 'modified')
  end

  def notify_change_cr(change_request, type)
    attachment = @attachment_builder.generate_change_request_attachment(change_request)
    link = change_request_url(change_request)
    approvers = change_request.approvals.collect{|approval| approval.user}
    approver_message = "#{type.humanize} <#{link}|change request> needs your approvals"
    notify_users(approvers, approver_message, attachment)
    associated_users = change_request.associated_users.to_a
    approvers.each {|approver| associated_users.delete(approver)}
    general_message = "<#{link}|Change request> has been #{type}"
    message_users(associated_users, general_message, attachment)
    message_channel('cab', general_message, attachment)
  end

  def notify_approved_cr(change_request)
    attachment = @attachment_builder.generate_approved_cr_attachment(change_request)
    link = change_request_url(change_request)
    associated_users = change_request.associated_users.to_a
    general_message = "New update on <#{link}|change request>"
    message_users(associated_users, general_message, attachment)
  end

  def notify_rejected_cr(change_request)
    attachment = @attachment_builder.generate_rejected_cr_attachment(change_request)
    link = change_request_url(change_request)
    associated_users = change_request.associated_users.to_a
    general_message = "New update on <#{link}|change request>"
    message_users(associated_users, general_message, attachment)
  end

  def notify_new_comment(comment)
    attachment = @attachment_builder.generate_comment_attachment(comment)
    link = change_request_url(comment.change_request)
    mentionees =  Mentioner.process_mentions(comment)
    if !mentionees.empty?
      mentioned_message = "You are mentioned in #{comment.user.name} comment's on a <#{link}|change request>"
      message_users(mentionees, mentioned_message, attachment)
    end
    associated_users = comment.change_request.associated_users.to_a
    associated_users.delete(comment.user)
    mentionees.each {|mentionee| associated_users.delete(mentionee)}
    general_message = "A new comment from #{comment.user.name} on a <#{link}|change request>"
    message_users(associated_users, general_message, attachment)
  end


  def notify_new_ir(incident_report)
    notify_change_ir(incident_report, 'created')
  end

  def notify_change_ir(incident_report, type)
    attachment = @attachment_builder.generate_incident_report_attachment(incident_report)
    link = incident_report_url(incident_report)
    general_message = "<#{link}|Incident report> has been #{type}"
    message_channel('incidents', general_message, attachment)
  end

  private
  def get_slack_username(user)
    @members.select { |u| user.email == u.profile.email }.first.try(:name)
  end

  def reassign_slack_username(user)
    user.slack_username = get_slack_username(user)
    user.save
  end

  def try_send(user, message, attachments)
    tries ||= 2
    @client.chat_postMessage(channel: "@#{user.slack_username}", text: message, attachments: attachments)
  rescue Slack::Web::Api::Error => e
    return if e.message != 'channel_not_found'
    reassign_slack_username(user)
    retry unless (tries -= 1).zero?
  end

  def notify_users(users, message, attachment)
    users.each do |user|
      actionable_attachment = @attachment_builder.wrap_approver_actions(attachment, user)
      try_send(user, message, [actionable_attachment])
    end
  end

  private
  def message_users(users, message, attachment)
    users.each do |user|
      try_send(user, message, [attachment])
    end
  end

  def message_channel(channel, message, attachment)
    @client.chat_postMessage(channel: "##{channel}", text: message, attachments: [attachment])
  end

end
