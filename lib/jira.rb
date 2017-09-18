class Jira
  include ActionView::Helpers::SanitizeHelper

  def initialize
    options = {
      :username     => ENV['JIRA_USERNAME'],
      :password     => ENV['JIRA_PASSWORD'],
      :site         => ENV['JIRA_URL'],
      :context_path => '',
      :auth_type    => :basic
    }
    @client = JIRA::Client.new(options)
  end

  def get_issue(key)
    begin
      issue = @client.Issue.find(key)
    rescue JIRA::HTTPError => e
      return key
    end
    
    summary = sanitize(issue.fields['summary'], tags: [])
    issue_type_icon = issue.fields['issuetype']['iconUrl']
    status_category = issue.fields['status']['statusCategory']
    color_name = status_category['colorName']
    name = status_category['name']
    url = URI::join(ENV['JIRA_URL'],'/browse/',key)

    html  = "<span class='jira-button'>"
    html << "  <a href='#{url}' target='_blank' data-toggle='popover' title='Summary' data-content='#{summary}'><img class='icon' src='#{issue_type_icon}'> #{key} </a>"
    html << "  <span class='jira-#{color_name.downcase}'>#{name}</span>"
    html << "</span>"
  end

  def jiraize(text)
    return '' if text.nil?
    matches = text.scan(/([A-Z]+-\d+)/).map { |x| [x[0], get_issue(x[0])] }
    for m in matches
      text.gsub! m[0], m[1]
    end
    return text
  end
end