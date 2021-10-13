require 'rails_helper'
require 'jira'
require 'jira_helpers.rb'

RSpec.configure do |c|
  c.include JiraHelpers
end

describe Jira do
  let(:jira) {Jira.new}
  describe 'generate jira html object' do
    let(:html) {
                "<span class='jira-button'>" \
                "  <a href='https://visiondemo.atlassian.net/browse/TEST-123' target='_blank' data-toggle='popover' title='Summary' data-content='summary'>" \
                "    <img class='icon' src='https://visiondemo.atlassian.net/images/icons/statuses/generic.png'> TEST-123 </a>" \
                "  <span class='jira-yellow'>In Progress</span>" \
                "</span>" \
                }
    let(:html_other) {
                "<span class='jira-button'>" \
                "  <a href='https://visiondemo.atlassian.net/browse/TEST-999' target='_blank' data-toggle='popover' title='Summary' data-content='summary'>" \
                "    <img class='icon' src='https://visiondemo.atlassian.net/images/icons/statuses/generic.png'> TEST-999 </a>" \
                "  <span class='jira-yellow'>In Progress</span>" \
                "</span>" \
                }

    it 'mention jira in change_request' do
      generate_jira_jql_link(["TEST-123", "TEST-999"])
      jira_change_request = FactoryBot.create(:jira_change_request)
      jira_change_request = jira.jiraize_cr(jira_change_request)

      expect(jira_change_request.net).to eq html
      expect(jira_change_request.os).to eq html
      expect(jira_change_request.db).to eq html
      expect(jira_change_request.analysis).to eq html
      expect(jira_change_request.impact).to eq html_other
      expect(jira_change_request.solution).to eq html
    end

    it 'mention jira in incident_report' do
      generate_jira_jql_link(["TEST-123"])

      jira_incident_report = FactoryBot.create(:jira_incident_report)
      jira_incident_report = jira.jiraize_ir(jira_incident_report)

      expect(jira_incident_report.action_item).to eq html
    end
  end

  describe 'not generate jira html object' do
    it 'mention jira in change_request' do
      WebMock.disable!
      jira_change_request = FactoryBot.create(:jira_change_request)
      jira_change_request = jira.jiraize_cr(jira_change_request)
      WebMock.enable!

      expect(jira_change_request.net).to eq "TEST-123"
      expect(jira_change_request.os).to eq "TEST-123"
      expect(jira_change_request.db).to eq "TEST-123"
      expect(jira_change_request.analysis).to eq "TEST-123"
      expect(jira_change_request.impact).to eq "TEST-999"
      expect(jira_change_request.solution).to eq "TEST-123"
    end

    it 'mention jira in incident_report' do
      WebMock.disable!
      jira_incident_report = FactoryBot.create(:jira_incident_report)
      jira_incident_report = jira.jiraize_ir(jira_incident_report)
      WebMock.enable!
      
      expect(jira_incident_report.action_item).to eq "TEST-123"
    end
  end
end