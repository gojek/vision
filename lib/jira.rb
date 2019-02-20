# frozen_string_literal: true

class Jira
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
    @jira_data = []
  end

  def get_issue(key)
    issue = nil
    @jira_data.each do |jira|
      issue = jira if jira.key==key
    end
    return key if issue.nil?

    summary = sanitize(issue.fields['summary'], tags: [])
    issue_type_icon = issue.fields['issuetype']['iconUrl']
    status_category = issue.fields['status']['statusCategory']
    color_name = status_category['colorName']
    name = status_category['name']
    url = URI.join(ENV['JIRA_URL'], '/browse/', key)

    "<span class='jira-button'>" \
    "  <a href='#{url}' target='_blank' data-toggle='popover' title='Summary' data-content='#{summary}'>" \
    "    <img class='icon' src='#{issue_type_icon}'> #{key}" \
    '  </a>' \
    "  <span class='jira-#{color_name.downcase}'>#{name}</span>" \
    '</span>'
  end

  def get_jira_data(list_issue)
    begin
      @jira_data = @client.Issue.jql(list_issue, {fields: %w(summary status issuetype),fields_by_key:true})
    rescue JIRA::HTTPError => e
      @jira_data = []
    end
  end

  def jiraize(text)
    return '' if text.nil?
    matches = text.scan(/([A-Z]+-\d+)/).map { |x| [x[0], get_issue(x[0])] }
    matches.each do |m|
      text.gsub! m[0], m[1]
    end
    text
  end

  def generate_issue_list(issue_string)
    if issue_string.count == 1
      get_jira_data('issueKey='+issue_string[0])
    else
      list_issue = ""
      issue_string.each do |text|
        list_issue += "issueKey="+text + " OR "
      end
      get_jira_data(list_issue[0..-5])
    end
  end

  def jiraize_ir(text)
    list = text.scan(/([A-Z]+-\d+)/).flatten
    generate_issue_list(list)
    jiraize(text)
  end

  def jiraize_cr(change_request)
    list = []
    list << change_request.business_justification.scan(/([A-Z]+-\d+)/) if change_request.business_justification.present?
    list << change_request.os.scan(/([A-Z]+-\d+)/) if change_request.os.present?
    list << change_request.db.scan(/([A-Z]+-\d+)/) if change_request.db.present?
    list << change_request.net.scan(/([A-Z]+-\d+)/) if change_request.net.present?
    list << change_request.other_dependency.scan(/([A-Z]+-\d+)/) if change_request.other_dependency.present?
    list << change_request.analysis.scan(/([A-Z]+-\d+)/) if change_request.analysis.present?
    list << change_request.impact.scan(/([A-Z]+-\d+)/) if change_request.impact.present?
    list << change_request.solution.scan(/([A-Z]+-\d+)/) if change_request.solution.present?
    generate_issue_list(list.flatten)

    change_request.business_justification = jiraize(change_request.business_justification)
    change_request.os = jiraize(change_request.os)
    change_request.db = jiraize(change_request.db)
    change_request.net = jiraize(change_request.net)
    change_request.other_dependency = jiraize(change_request.other_dependency)
    change_request.analysis = jiraize(change_request.analysis)
    change_request.impact = jiraize(change_request.impact)
    change_request.solution = jiraize(change_request.solution)
    return change_request
  end
end
