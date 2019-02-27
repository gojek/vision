require 'spec_helper'
require 'slack_notif'
require 'slack_attachment_builder.rb'

describe SlackNotif do
  let(:user) {FactoryGirl.create(:approver, email: 'dwiyan@veritrans.co.id', slack_username: 'dwiyan')}
  let(:other_user) {FactoryGirl.create(:approver, email: 'kevin@veritrans.co.id', slack_username: 'kevin')}
  let(:change_request) {FactoryGirl.create(:change_request)}
  let(:incident_report) {FactoryGirl.create(:incident_report)}
  let(:access_request) {FactoryGirl.create(:access_request)}
  let(:slack_notifier) {SlackNotif.new}
  let(:attachment_builder) {SlackAttachmentBuilder.new}
  let(:slack_client) {slack_notifier.instance_variable_get(:@slack_client)}
  let(:routes) {Rails.application.routes.url_helpers}
  let(:change_request_link){routes.change_request_url(change_request)}
  let(:incident_report_link){routes.incident_report_url(incident_report)}
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
        expect(slack_client).to receive(:message_users).with(approvers, approver_message, change_request_attachment)
        expect(slack_client).to receive(:message_users).with(associated_users, new_cr_message, change_request_attachment)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send general message to spesified change request channel' do
        expect(slack_client).to receive(:message_channel).with(change_request_channel, new_cr_message, anything())
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Send attachment from attachment builder' do
        expect(slack_client).to receive(:message_users).with(anything(), approver_message, change_request_attachment)
        expect(slack_client).to receive(:message_users).with(anything(), anything(), change_request_attachment)
        expect(slack_client).to receive(:message_channel).with(anything(), anything(), change_request_attachment)
        slack_notifier.notify_new_cr(change_request)
      end

      it 'Failed send general message to cab channel' do
        stub_request(:post, "https://slack.com/api/chat.postMessage")
          .to_return(status: 200, body: '{"ok": false, "error":"channel_not_found"}', headers: {})
        stub_request(:post, "https://slack.com/api/users.lookupByEmail").
          to_return(status: 200, body: '{"ok": false, "error":"users_not_found"}', headers: {})
          
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
        expect(slack_client).to receive(:message_users).with(approvers, approver_message, change_request_attachment)
        expect(slack_client).to receive(:message_users).with(associated_users, modified_cr_message, anything())
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send message to spesified change request channel' do
        general_message = "<#{change_request_link}|Change request> has been modified"
        expect(slack_client).to receive(:message_channel).with(change_request_channel, modified_cr_message, anything())
        slack_notifier.notify_update_cr(change_request)
      end

      it 'Send attachment from attachment builder' do
        expect(slack_client).to receive(:message_users).with(anything(), approver_message, change_request_attachment)
        expect(slack_client).to receive(:message_users).with(anything(), anything(), change_request_attachment)
        expect(slack_client).to receive(:message_channel).with(anything(), anything(), change_request_attachment)
        slack_notifier.notify_update_cr(change_request)
      end
    end
  end

  describe 'Sending notification about new comment' do
    let(:another_user) {FactoryGirl.create(:user)}
    let(:comment) {FactoryGirl.create(:comment, body: 'comment @dwiyan and @kevin', user: user, change_request: change_request)}
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
    let(:another_user) {FactoryGirl.create(:user)}
    let(:comment) {FactoryGirl.create(:access_request_comment, body: 'comment @dwiyan and @kevin', user: user, access_request: access_request)}
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
    it 'Send message to incident report slack channel' do
      general_message = "<#{incident_report_link}|Incident report> has been created"
      expect(slack_client).to receive(:message_channel).with(incident_report_channel, general_message, anything())
      slack_notifier.notify_new_ir(incident_report)
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
