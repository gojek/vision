require 'spec_helper'
require 'slack_attachment_builder.rb'

describe SlackAttachmentBuilder do
  let(:user) {FactoryGirl.create(:approver, slack_username: "dwiyan")}
  let(:change_request) {FactoryGirl.create(:change_request)}
  let(:incident_report) {FactoryGirl.create(:incident_report)}
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
      expect(attachment_generated[:fields]).to include({
        title: "Deployment Time",
        value: change_request.schedule_change_date,
        short: false
      })
    end

    it 'put approvers as field in attachment' do
      attachment_generated = attachment_builder.generate_change_request_attachment(change_request)
      approvers_name = change_request.approvals.includes(:user).pluck(:name)
      expect(attachment_generated[:fields]).to include({
        title: "Approvers", 
        value: (approvers_name.join ', '), 
        short: false
      })      
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

  describe 'generate approved cr attachment' do
    let(:approved_change_request) {FactoryGirl.create(:change_request)}
    let(:approval) {FactoryGirl.create(:approval, change_request_id: approved_change_request.id, approve: true, notes: 'Ok')}

    it 'put change summary in fallback' do
      attachment_generated = attachment_builder.generate_approved_cr_attachment(approved_change_request, approval)
      expect(attachment_generated).to include(fallback: approved_change_request.change_summary)
    end

    it 'put id and change summary in title' do
      attachment_generated = attachment_builder.generate_approved_cr_attachment(approved_change_request, approval)
      expect(attachment_generated).to include(title: "#{approved_change_request.id}. #{approved_change_request.change_summary}")
    end

    it 'put approval status as field in attachment' do
      attachment_generated = attachment_builder.generate_approved_cr_attachment(approved_change_request, approval)
      expect(attachment_generated[:fields]).to include({
        title: "Approval Status",
        value: "Approved by #{approval.user.name}",
        short: false
      })
    end

    it 'put note as field in attachment' do
      attachment_generated = attachment_builder.generate_approved_cr_attachment(approved_change_request, approval)
      expect(attachment_generated[:fields]).to include({
        title: "Note",
        value: "#{approval.notes}",
        short: false
      })
    end

    it 'put vt-vision as footer in attachment' do
      attachment_generated = attachment_builder.generate_approved_cr_attachment(approved_change_request, approval)
      expect(attachment_generated).to include(footer: "VT-Vision")
    end

    it 'put cr created date in timestamp' do
      attachment_generated = attachment_builder.generate_approved_cr_attachment(approved_change_request, approval)
      expect(attachment_generated).to include(ts: approved_change_request.created_at.to_datetime.to_f.round)
    end
  end

  describe 'generate incident report attachment' do
    it 'put service impact in fallback' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated).to include(fallback: incident_report.service_impact)
    end

    it 'put id and service impact in title' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated).to include(title: "#{incident_report.id}. #{incident_report.service_impact}")
    end

    it 'put source as field in attachment' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated[:fields]).to include({
        title: "Source", 
        value: incident_report.source, 
        short: true
      })
    end

    it 'put level as field in attachment' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated[:fields]).to include({
        title: "Level", 
        value: incident_report.rank, 
        short: true
      })
    end
    
    it 'put occurence time as field in attachment' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated[:fields]).to include({
        title: "Occurence Time", 
        value: incident_report.occurrence_time, 
        short: false
      })
    end

    it 'put reporter as field in attachment' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated[:fields]).to include({
        title: "Reporter", 
        value: incident_report.user.name, 
        short: false
      })
    end

    it 'put created_at as timestamp' do
      attachment_generated = attachment_builder.generate_incident_report_attachment(incident_report)
      expect(attachment_generated).to include(ts: incident_report.created_at.to_datetime.to_f.round)
    end

    it 'use url_helpers to generate link before put into title_link' do
      expect(attachment_builder).to receive(:incident_report_url).with(incident_report)
      attachment_builder.generate_incident_report_attachment(incident_report)
    end

    it 'use SanitizeHelper to sanitize bussines Justification before put into field attachment' do
      expect(attachment_builder).to receive(:sanitize).with(incident_report.problem_details, tags: [])
      attachment_builder.generate_incident_report_attachment(incident_report)
    end

    it 'use DateHelper to compute distance time in words before put into field attachment' do
      expect(attachment_builder).to receive(:distance_of_time_in_words).with(incident_report.recovery_duration * 60)
      attachment_builder.generate_incident_report_attachment(incident_report)
    end
  end
end
