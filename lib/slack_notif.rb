require 'slack_client.rb'
require 'mentioner.rb'
require 'slack_attachment_builder.rb'

class SlackNotif
  include Rails.application.routes.url_helpers

  def initialize
    @slack_client = SlackClient.new
    @attachment_builder = SlackAttachmentBuilder.new
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
    approvers = change_request.approvals.collect(&:user)
    approver_message = "#{type.humanize} <#{link}|change request> needs your approvals"
    notify_approvers(approvers, approver_message, attachment)
    associated_users = change_request.associated_users.to_a
    approvers.each { |approver| associated_users.delete(approver) }
    general_message = "<#{link}|Change request> has been #{type}"
    @slack_client.message_users(associated_users, general_message, attachment)
    @slack_client.message_channel('cab', general_message, attachment)
  end

  def notify_change_ar(access_request, type)
    attachment = @attachment_builder.generate_access_request_attachment(access_request)
    link = access_request_url(access_request)
    approvers = access_request.approvals.collect(&:user)
    approver_message = "#{type.humanize} <#{link}|access_request> needs your approvals"
    notify_approvers(approvers, approver_message, attachment)
  end

  def notify_approval_status_cr(change_request, approval)
    attachment = @attachment_builder.generate_approval_status_cr_attachment(change_request, approval)
    link = change_request_url(change_request)
    associated_users = change_request.associated_users.to_a
    general_message = "New update on <#{link}|Change request>"
    @slack_client.message_users(associated_users, general_message, attachment)
  end

  def notify_new_comment(comment)
    attachment = @attachment_builder.generate_comment_attachment(comment)
    link = change_request_url(comment.change_request)
    mentionees =  Mentioner.process_mentions(comment)
    if !mentionees.empty?
      mentioned_message = "You are mentioned in #{comment.user.name} comment's on a <#{link}|Change request>"
      @slack_client.message_users(mentionees, mentioned_message, attachment)
    end
    associated_users = comment.change_request.associated_users.to_a
    associated_users.delete(comment.user)
    mentionees.each {|mentionee| associated_users.delete(mentionee)}
    general_message = "A new comment from #{comment.user.name} on a <#{link}|Change request>"
    @slack_client.message_users(associated_users, general_message, attachment)
  end

  def notify_new_ar_comment(ar_comment)
    attachment = @attachment_builder.generate_ar_comment_attachment(ar_comment)
    link = access_request_url(ar_comment.access_request)
    mentionees = Mentioner.process_mentions(ar_comment)
    if !mentionees.empty?
      mentioned_message = "You are mentioned in #{ar_comment.user.name} comment's on a <#{link}|access request>"
      @slack_client.message_users(mentionees, mentioned_message, attachment)
    end
    associated_users = ar_comment.access_request.collaborators.to_a
    associated_users.delete(ar_comment.user)
    mentionees.each { |mentionee| associated_users.delete(mentionee) }
    general_message = "A new comment from ${comment.user.name} on a <#{link}|access request>"
    @slack_client.message_users(associated_users, general_message, attachment)
  end

  def notify_terminate_cr(change_request, status)
    attachment = @attachment_builder.generate_simple_change_request_attachment(change_request)
    link = change_request_url(change_request)
    general_message = "<#{link}|Change request> has been #{status}"
    @slack_client.message_channel('cab', general_message, attachment)
  end


  def notify_new_ir(incident_report)
    notify_change_ir(incident_report, 'created')
  end

  def notify_change_ir(incident_report, type)
    attachment = @attachment_builder.generate_incident_report_attachment(incident_report)
    link = incident_report_url(incident_report)
    general_message = "<#{link}|Incident report> has been #{type}"
    @slack_client.message_channel('incidents', general_message, attachment)
  end

  def notify_new_access_request(access_request)
    attachment = @attachment_builder.generate_access_request_attachment(access_request)
    link = access_request_url(access_request)
    general_message = "<#{link}|Access request> has been created for #{access_request.employee_name}(#{access_request.employee_department})"
    @slack_client.message_users(access_request.associated_users, general_message, attachment)
  end

  private
  def notify_approvers(users, message, attachment)
    actionable_attachment = @attachment_builder.wrap_approver_actions(attachment)
    @slack_client.message_users(users, message, attachment)
  end
end
