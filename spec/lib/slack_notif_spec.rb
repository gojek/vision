require 'spec_helper'
require 'slack_notif'

describe SlackNotif do
  let(:user) {FactoryGirl.create(:approver)}
  let(:change_request) {FactoryGirl.create(:change_request)}
  let(:slack_notifier) {SlackNotif.client}

  describe "Sending notification to approver about new CR" do

    context "When all user's slack usernames known" do
      let(:other_user) {FactoryGirl.create(:approver)}

      it "Send message to all appropriate approver's username of the CR" do
        user.update(slack_username: "dwiyan")
        other_user.update(slack_username: "kevin")
        change_request.update(approvals: [Approval.create(user: user), Approval.create(user: other_user)])

        expect(slack_notifier).to receive(:chat_postMessage).twice
        SlackNotif.notif_new_request(change_request, "http://example.com")
      end
    end

    context "When user's slack username unknown" do
      it "does not send the message" do
        change_request.update(approvals: [Approval.create(user: user)])

        expect(slack_notifier).not_to receive(:chat_postMessage)
        SlackNotif.notif_new_request(change_request, "http://example.com")
      end
    end
  end

  describe "Sending notification to mentionees about comment that they are mentioned" do
    let(:comment) {FactoryGirl.create(:comment, user: user, change_request: change_request)}

    context "When all user's slack usernames known" do
      let(:other_user) {FactoryGirl.create(:approver)}

      it "Send message to all appropriate mentionee" do
        user.update(slack_username: "dwiyan")
        other_user.update(slack_username: "kevin")

        expect(slack_notifier).to receive(:chat_postMessage).twice
        SlackNotif.notif_comment_mention(comment, [user, other_user], "http://example.com")
      end
    end

    context "When user's slack username unknown" do
      it "does not send the message" do
        expect(slack_notifier).not_to receive(:chat_postMessage)
        SlackNotif.notif_comment_mention(comment, [user], "http://example.com")
      end
    end
  end
end
