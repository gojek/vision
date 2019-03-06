# frozen_string_literal: true

class Jira
  JIRA_KEY_REGEX = /[A-Z0-9]+-\d+/
  include ActionView::Helpers::SanitizeHelper
  attr_accessor :client, :jira_data

  def initialize
    options = {
      username: ENV['JIRA_USERNAME'],
      password: ENV['JIRA_PASSWORD'],
      site: ENV['JIRA_URL'],
      context_path: '',
      auth_type: :basic
    }
    @client = JIRA::Client.new(options)
    @jira_data = {}
  end

  def jiraize_ir(incident_report)
    list = find_jira_key(incident_report.action_item)
    return incident_report if list.blank?
    generate_issue_list(list)
    incident_report.action_item = jiraize(incident_report.action_item)
    incident_report
  end

  def jiraize_cr(change_request)
    list = Set.new
    list.merge(find_jira_key(change_request.business_justification))
    list.merge(find_jira_key(change_request.os))
    list.merge(find_jira_key(change_request.db))
    list.merge(find_jira_key(change_request.net))
    list.merge(find_jira_key(change_request.other_dependency))
    list.merge(find_jira_key(change_request.analysis))
    list.merge(find_jira_key(change_request.impact))
    list.merge(find_jira_key(change_request.solution))
    list.delete('')
    generate_issue_list(list.flatten)

    change_request.business_justification = jiraize(change_request.business_justification)
    change_request.os = jiraize(change_request.os)
    change_request.db = jiraize(change_request.db)
    change_request.net = jiraize(change_request.net)
    change_request.other_dependency = jiraize(change_request.other_dependency)
    change_request.analysis = jiraize(change_request.analysis)
    change_request.impact = jiraize(change_request.impact)
    change_request.solution = jiraize(change_request.solution)
    change_request
  end

  def jiraize(text)
    return text if text.blank?
    text.gsub(JIRA_KEY_REGEX) { |key| get_issue(key) }
  end

  def get_issue(key)
    return key unless (issue = @jira_data[key])

    summary = sanitize(issue.fields['summary'], tags: [])
    issue_type_icon = issue.fields['issuetype']['iconUrl']
    status_category = issue.fields['status']['statusCategory']
    color_name = status_category['colorName']
    name = status_category['name']
    url = URI.join(ENV['JIRA_URL'], '/browse/', key)

    "<span class='jira-button'>" \
    "  <a href='#{url}' target='_blank' data-toggle='popover' title='Summary' data-content='#{summary}'>" \
    "    <img class='icon' src='#{issue_type_icon}'> #{key} </a>" \
    "  <span class='jira-#{color_name.downcase}'>#{name}</span>" \
    '</span>'
  end

  def generate_issue_list(issue_string)
    return if issue_string.empty?
    list_issue = issue_string.map { |item| "issueKey=#{item}" }.join(' OR ')
    get_jira_data(list_issue)
  end

  def get_jira_data(list_issue)
    raw_issues = @client.Issue.jql(list_issue,
                                   fields: %w[summary status issuetype], fields_by_key: true, validate_query: false)
    raw_issues.each do |issue|
      @jira_data[issue.key] = issue
    end
  rescue JIRA::HTTPError
    @jira_data
  end

  def find_jira_key(text)
    return [] if text.blank?
    jira_keys = text.scan(JIRA_KEY_REGEX)
    jira_keys.present? ? jira_keys : []
  end
end
