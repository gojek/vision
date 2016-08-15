require 'spec_helper'
require 'slack_notif'
require 'slack_attachment_builder.rb'

describe SlackNotif do
  let(:user) {FactoryGirl.create(:approver, email: 'dwiyan@veritrans.co.id', slack_username: 'dwiyan')}
  let(:other_user) {FactoryGirl.create(:approver, email: 'kevin@veritrans.co.id', slack_username: 'kevin')}
  let(:change_request) {FactoryGirl.create(:change_request)}
  let(:slack_notifier) {SlackNotif.new}
  let(:attachment_builder) {SlackAttachmentBuilder.new}
  let(:routes) {Rails.application.routes.url_helpers}
  let(:change_request_link){routes.change_request_url(change_request)}

  describe 'Notify about change request' do
    let(:change_request_attachment){attachment_builder.generate_change_request_attachment(change_request)}
    let(:new_cr_message) {"New <#{change_request_link}|change request> has been created"}
    let(:approver_message) {"New <#{change_request_link}|change request> needs your approvals"}

    describe 'Sending notification about new CR' do
      it 'Send message to all appropriate approvers of the CR' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        expect(slack_notifier).to receive(:message_users).with(approvers, approver_message, anything())
        expect(slack_notifier).to receive(:message_users)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send message to all associated users of the CR except approvers' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        associated_users = approvers + [user, other_user]
        change_request.update(associated_users: associated_users)
        change_request.reload
        expect(slack_notifier).to receive(:message_users).with(associated_users - approvers, new_cr_message, anything())
        expect(slack_notifier).to receive(:message_users)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send general message to cab channel' do
        expect(slack_notifier).to receive(:message_channel).with('cab', new_cr_message, anything())
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send attachment from attachment builder' do
        expect(slack_notifier).to receive(:message_users).with(anything(), anything(), change_request_attachment).twice
        expect(slack_notifier).to receive(:message_channel).with(anything(), anything(), change_request_attachment)
        slack_notifier.notify_new_cr(change_request)
      end
    end

    describe 'Sending notification about modified CR' do
      it 'Send message to all appropriate approvers of the CR' do
        approver_message = "Modified <#{change_request_link}|change request> needs your approvals"
        approvers = change_request.approvals.collect{|approval| approval.user}
        expect(slack_notifier).to receive(:message_users).with(approvers, approver_message, anything())
        expect(slack_notifier).to receive(:message_users)
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send general message to all associated users of the CR except approvers' do
        approvers = change_request.approvals.collect{|approval| approval.user}
        change_request.update(associated_users: approvers + [user, other_user])
        change_request.reload
        general_message = "<#{change_request_link}|Change request> has been modified"
        associated_users = change_request.associated_users
        expect(slack_notifier).to receive(:message_users).with(associated_users - approvers, general_message, anything())
        expect(slack_notifier).to receive(:message_users)
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send message to cab channel' do
        general_message = "<#{change_request_link}|Change request> has been modified"
        expect(slack_notifier).to receive(:message_channel).with('cab', general_message, anything())
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send attachment from attachment builder' do
        expect(slack_notifier).to receive(:message_users).with(anything(), anything(), change_request_attachment).twice
        expect(slack_notifier).to receive(:message_channel).with(anything(), anything(), change_request_attachment)
        slack_notifier.notify_update_cr(change_request)
      end
    end
  end

  describe 'Sending notification about new comment' do
    let(:another_user) {FactoryGirl.create(:user)}
    let(:comment) {FactoryGirl.create(:comment, body: 'comment @dwiyan and @kevin', user: user, change_request: change_request)}
    let(:mentionees){[user, other_user]}
    let(:comment_attachment){attachment_builder.generate_comment_attachment(comment)}

    it 'Send message to mentionees that they are mentioned' do
      mentioned_message = "You are mentioned in #{comment.user.name} comment's on a <#{change_request_link}|change request>"
      expect(slack_notifier).to receive(:message_users).with(mentionees, mentioned_message, anything())
      expect(slack_notifier).to receive(:message_users)
      slack_notifier.notify_new_comment(comment)
    end

    it 'Send message to associated_users about new comment except mentionees' do
      associated_users = [user, other_user, another_user]
      change_request.update(associated_users: associated_users)
      change_request.reload
      general_message = "A new comment from #{comment.user.name} on a <#{change_request_link}|change request>"
      expect(slack_notifier).to receive(:message_users).with(associated_users - mentionees, general_message, anything())
      expect(slack_notifier).to receive(:message_users)
      slack_notifier.notify_new_comment(comment)
    end

    it 'Send attachment from attachment builder' do
      expect(slack_notifier).to receive(:message_users).with(anything(), anything(), comment_attachment).twice
      slack_notifier.notify_new_comment(comment)
    end
  end
end
