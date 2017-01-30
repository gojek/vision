require 'spec_helper'
require 'slack_attachment_builder.rb'

describe SlackAttachmentBuilder do
  let(:user) {FactoryGirl.create(:approver, slack_username: "dwiyan")}
  let(:change_request) {FactoryGirl.create(:change_request)}
  let(:comment) {FactoryGirl.create(:comment, user: user, change_request: change_request)}
  let(:attachment_builder) {SlackAttachmentBuilder.new}

  describe 'generate change request attachment' do
    it 'put change summary as title and fallback' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      expect(attachment_generated).to include(title: change_request.change_summary)
      expect(attachment_generated).to include(fallback: change_request.change_summary)
    end

    it 'put created_at as timestamp' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      expect(attachment_generated).to include(ts: change_request.created_at.to_datetime.to_f.round)
    end

    it 'use url_helpers to generate link before put into title_link' do
      expect(attachment_builder).to receive(:change_request_url).with(change_request)
      attachment_builder.generate_change_request_attachment(change_request)
    end

    it 'put scope as field in attachment' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      expect(attachment_generated[:fields]).to include({title: "Scope", value: change_request.scope, short: true})
    end

    it 'put priority as field in attachment' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      expect(attachment_generated[:fields]).to include({title: "Priority", value: change_request.priority, short: true})
    end

    it 'use SanitizeHelper to sanitize bussines Justification before put into field attachment' do
      expect(attachment_builder).to receive(:sanitize).with(change_request.business_justification, tags: [])
      attachment_builder.generate_change_request_attachment(change_request)
    end

    it 'put deployment_time as field in attachment' do 
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      expect(attachment_generated[:fields]).to include({title: "Deployment Time", value: change_request.schedule_change_date, short: false})
    end

    it 'put approvers as field in attachment' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      approvers = change_request.approvals.pluck(:user_id)
      approvers_name = approvers.collect {|id| User.find(id).name}
      expect(attachment_generated[:fields]).to include({title: "Approvers", value: (approvers_name.join ', '), short: false})      
    end

  end

  describe 'generate comment attachment' do
    it 'put comment body as text and fallback' do
      attachment_generated = attachment_builder.generate_comment_attachment(comment)
      expect(attachment_generated).to include(text: comment.body)
      expect(attachment_generated).to include(fallback: comment.body)
    end

    it 'put comment body as title' do
      attachment_generated = attachment_builder.generate_comment_attachment(comment)
      expect(attachment_generated).to include(title: change_request.change_summary)
    end

    it 'put created_at as timestamp' do
      attachment_generated = attachment_builder.generate_comment_attachment(comment)
      expect(attachment_generated).to include(ts: comment.created_at.to_datetime.to_f.round)
    end

    it 'use url_helpers to generate link before put into title_link' do
      expect(attachment_builder).to receive(:change_request_url).with(change_request)
      attachment_builder.generate_comment_attachment(comment)
    end
  end
end
