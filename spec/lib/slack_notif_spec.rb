require 'rails_helper'
require 'slack_notif'
require 'slack_attachment_builder.rb'
require 'slack_helpers.rb'

RSpec.configure do |c|
  c.include SlackHelpers
end

describe SlackNotif do
  let(:user) {FactoryBot.create(:approver, email: 'approver@gmail.com', slack_username: 'approver')}
  let(:other_user) {FactoryBot.create(:approver, email: 'approver2@gmail.com', slack_username: 'approver2')}
  let(:change_request) {FactoryBot.create(:change_request)}
  let(:access_request) {FactoryBot.create(:access_request)}
  let(:slack_notifier) {SlackNotif.new}
  let(:attachment_builder) {SlackAttachmentBuilder.new}
  let(:slack_client) {slack_notifier.instance_variable_get(:@slack_client)}
  let(:routes) {Rails.application.routes.url_helpers}
  let(:change_request_link){routes.change_request_url(change_request)}
  let(:access_request_link){routes.access_request_url(access_request)}
  let(:change_request_channel) { ENV['SLACK_CR_CHANNEL'] }
  let(:incident_report_channel) { ENV['SLACK_IR_CHANNEL'] }

  describe 'Notify about change request' do
    let(:change_request_attachment){attachment_builder.generate_change_request_attachment(change_request)}

    describe 'Sending notification about approval status CR' do
      let(:change_request_approval_status_attachment){attachment_builder.generate_approval_status_cr_attachment(change_request, change_request.approvals.first)}
      let(:general_message) {"New update on <#{change_request_link}|Change request>"}
      it 'Send message to associated_users' do
        associated_users = change_request.associated_users
        expect(slack_client).to receive(:message_users).with(associated_users, general_message, change_request_approval_status_attachment)
        slack_notifier.notify_approval_status_cr(change_request, change_request.approvals.first)
      end
    end

    describe 'Sending notification about new CR' do
      let(:new_cr_message) {"<#{change_request_link}|Change request> has been created"}
      let(:approver_message) {"Created <#{change_request_link}|change request> needs your approvals"}

      it 'Send notify to all appropriate approvers of the CR' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        expect(slack_notifier).to receive(:notify_approvers).with(approvers, approver_message, change_request_attachment)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send message to all associated users of the CR except approvers' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        change_request.update(associated_users: approvers + [user, other_user])
        change_request.reload
        associated_users = change_request.associated_users.to_a
        approvers.each {|approver| associated_users.delete(approver)}
        expect(slack_client).to receive(:message_users).with(approvers, approver_message,
          attachment_builder.wrap_approver_actions(change_request_attachment))
        expect(slack_client).to receive(:message_users).with(associated_users, new_cr_message, change_request_attachment)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send general message to spesified change request channel' do
        expect(slack_client).to receive(:message_channel).with(change_request_channel, new_cr_message, anything())
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send attachment from attachment builder' do
        expect(slack_client).to receive(:message_users).with(anything(), approver_message,
          attachment_builder.wrap_approver_actions(change_request_attachment))
        expect(slack_client).to receive(:message_users).with(anything(), anything(), change_request_attachment)
        expect(slack_client).to receive(:message_channel).with(anything(), anything(), change_request_attachment)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Failed send general message to cab channel' do
        error_not_found_stub('channel')
        error_not_found_stub('users')

        expect do
          slack_notifier.notify_new_cr(change_request)
        end.to raise_error(Slack::Web::Api::Error)
      end
    end

    describe 'Sending notification about modified CR' do
      let(:modified_cr_message) {"<#{change_request_link}|Change request> has been modified"}
      let(:approver_message) {"Modified <#{change_request_link}|change request> needs your approvals"}

      it 'Send message to all appropriate approvers of the CR' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        expect(slack_notifier).to receive(:notify_approvers).with(approvers, approver_message, anything())
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send general message to all associated users of the CR except approvers' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        change_request.update(associated_users: approvers + [user, other_user])
        change_request.reload
        associated_users = change_request.associated_users.to_a
        approvers.each {|approver| associated_users.delete(approver)}
        expect(slack_client).to receive(:message_users).with(approvers, approver_message,
          attachment_builder.wrap_approver_actions(change_request_attachment))
        expect(slack_client).to receive(:message_users).with(associated_users, modified_cr_message, anything())
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send message to spesified change request channel' do
        general_message = "<#{change_request_link}|Change request> has been modified"
        expect(slack_client).to receive(:message_channel).with(change_request_channel, modified_cr_message, anything())
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send attachment from attachment builder' do
        expect(slack_client).to receive(:message_users).with(anything(), approver_message,
          attachment_builder.wrap_approver_actions(change_request_attachment))
        expect(slack_client).to receive(:message_users).with(anything(), anything(), change_request_attachment)
        expect(slack_client).to receive(:message_channel).with(anything(), anything(), change_request_attachment)
        slack_notifier.notify_update_cr(change_request)
      end
    end
  end

  describe 'Sending notification about new comment' do
    let(:another_user) {FactoryBot.create(:user)}
    let(:comment) {FactoryBot.create(:comment, body: 'comment @approver and @approver2', user: user, change_request: change_request)}
    let(:mentionees){[user, other_user]}
    let(:comment_attachment){attachment_builder.generate_comment_attachment(comment)}
    let(:mentioned_message) {"You are mentioned in #{comment.user.name} comment's on a <#{change_request_link}|change request>"}
    let(:general_message) {"A new comment from #{comment.user.name} on a <#{change_request_link}|Change request>"}

    it 'Send message to mentionees that they are mentioned' do
      expect(slack_client).to receive(:message_users).twice
      slack_notifier.notify_new_comment(comment)
    end

    it 'Send message to associated_users about new comment except mentionees and the commenter itself' do
      change_request.update(associated_users: [user, other_user, another_user])
      change_request.reload
      associated_users = change_request.associated_users.to_a
      associated_users.delete(comment.user)
      mentionees.each {|mentionee| associated_users.delete(mentionee)}
      expect(slack_client).to receive(:message_users).twice
      slack_notifier.notify_new_comment(comment)
    end

    it 'Send attachment from attachment builder' do
      expect(slack_client).to receive(:message_users).with(anything(), anything(), comment_attachment).twice
      slack_notifier.notify_new_comment(comment)
    end
  end

  describe 'Sending notification about new comment AR' do
    let(:another_user) {FactoryBot.create(:user)}
    let(:comment) {FactoryBot.create(:access_request_comment, body: 'comment @approver and @approver2', user: user, access_request: access_request)}
    let(:mentionees){[user, other_user]}
    let(:comment_attachment){attachment_builder.generate_ar_comment_attachment(comment)}
    let(:mentioned_message) {"You are mentioned in #{comment.user.name} comment's on a <#{access_request_link}|access request>"}
    let(:general_message) {"A new comment from #{comment.user.name} on a <#{access_request_link}|access request>"}

    it 'Send message from attachment builder and mentionees that mentioned' do
      expect(slack_client).to receive(:message_users)
      expect(slack_client).to receive(:message_users).with(anything(), anything(), comment_attachment)
      slack_notifier.notify_new_ar_comment(comment)
    end
  end

  describe 'Sending notification about new Incident Report to sepesified incident report slack channel' do
    it 'Send message to correct incident report slack channel' do
      entity_channel = {
        'Engineering' => 'incident-report',
        'Qa' => 'incident-report2'
      }
      entity_channel.each do |entity, channel|
        ir = FactoryBot.create(:incident_report, entity_source: entity)
        general_message = "<#{routes.incident_report_url(ir)}|Incident report> has been created"
        expect(slack_client).to receive(:message_channel).with(channel, general_message, anything()).ordered
        slack_notifier.notify_new_ir(ir)
      end
    end
  end

  describe 'Sending notificaiton about new Access Request' do
    let(:access_request_attachment){attachment_builder.generate_access_request_attachment(access_request)}
    let(:approver_message) {"Created <#{access_request_link}|access_request> needs your approvals"}

    it 'Send message to all appropriate approvers of the AR' do
      approvers = access_request.approvals.collect{|approval| approval.user}
      expect(slack_notifier).to receive(:notify_approvers).with(approvers, approver_message, access_request_attachment)
      slack_notifier.notify_new_ar(access_request)
    end
  end
end
