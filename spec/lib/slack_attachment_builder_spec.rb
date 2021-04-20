require 'spec_helper'
require 'slack_attachment_builder.rb'

describe SlackAttachmentBuilder do
  let(:user) {FactoryGirl.create(:approver, slack_username: "dwiyan")}
  let(:change_request) {FactoryGirl.create(:change_request, change_summary: 'change summary')}
  let(:incident_report) {FactoryGirl.create(:incident_report, occurrence_time: Time.new("2011"))}
  let(:comment) {FactoryGirl.create(:comment, user: user, change_request: change_request, body: 'a comment')}
  let(:attachment_builder) {SlackAttachmentBuilder.new}

  before { Timecop.freeze(Time.new(2016, 1, 11, 0, 0, 0, "+07:00"))}
  after { Timecop.return() }

  describe 'generate change request attachment' do
    it 'construct a correct slack attachment structure' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      expect(attachment_generated).to matching(
        fallback: "change summary",
        color: "#439FE0",
        title: "#{change_request.id}. change summary",
        title_link: "http://localhost:3000/change_requests/#{change_request.id}",
        callback_id: change_request.id,
        fields: [
          { title: "Business Justification", value: "Business Justification", short: false },
          { title: "Priority", value: "Low", short: true },
          { title: "Scope", value: "Minor", short: true },
          { title: "Downtime Impact", value: "No expected Downtime", short: false },
          { title: "Deployment Time", value: Time.now, short: false },
          { title: "Approvers", value: "patrick star, patrick star", short: false }
        ],
        footer: "VT-Vision",
        ts: 1452445200
      )
    end
  end


  describe 'generate comment attachment' do
    it 'it construct comment attachment structure correctly' do
      attachment_generated = attachment_builder.generate_comment_attachment(comment)
      expect(attachment_generated).to matching(
        fallback: "a comment",
        text: "a comment",
        color: "#439FE0",
        title: "change summary",
        title_link: "http://localhost:3000/change_requests/#{change_request.id}",
        footer: "VT-Vision",
        ts: 1452445200
      )
    end
  end

  describe 'generate approved cr attachment' do
    let(:approval) {FactoryGirl.create(:approval, change_request_id: change_request.id, approve: true, notes: 'Ok')}

    it 'put change summary in fallback' do
      attachment_generated = attachment_builder.generate_approval_status_cr_attachment(change_request, approval)
      expect(attachment_generated).to matching(
        fallback: "change summary",
        color: "#439FE0",
        title: "#{change_request.id}. change summary",
        title_link: "http://localhost:3000/change_requests/#{change_request.id}",
        callback_id: change_request.id,
        fields: [
          { title: "Approval Status", value: "Approved by patrick star", short: false },
          { title: "Note", value: "Ok", short: false }
        ],
        footer: "VT-Vision",
        ts: 1452445200
      )
    end
  end

  describe 'generate incident report attachment' do
    it 'put service impact in fallback' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated).to matching(
        fallback: "Service impact",
        color: "#439FE0",
        title: "#{incident_report.id}. Service impact",
        title_link: "http://localhost:3000/incident_reports/#{incident_report.id}",
        callback_id: incident_report.id,
        fields:
        [
          { title: "Source", value: "Internal", short: true },
          { title: "Level", value: 1, short: true },
          { title: "Details", value: "Problem details", short: false },
          { title: "Occurrence Time", value: Time.new("2011"), short: false },
          { title: "Acknowledge Time", value: "2016-01-10 00:00:00 +0700 (1440 minutes)", short: false },
          { title: "Reporter", value: "patrick star", short: false }
        ],
        footer: "VT-Vision",
        ts: 1452445200
      )
    end
  end
end
