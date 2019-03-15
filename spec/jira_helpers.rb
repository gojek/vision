# frozen_string_literal: true

module JiraHelpers
  def generate_jira_jql_link(issues)
  jql = issues.map { |issue| URI.encode_www_form("issueKey"=>issue) }.join(" OR ")
  stub_request(:get, "https://veritrans.atlassian.net/rest/api/2/search?fields=summary,status,issuetype&jql="+jql+"&validateQuery=false")
      .to_return(
        status: 200, 
        body: '{"issues":[' + issues.map{ |issue| '
                {
                  "id":"1234",
                  "key":"'+issue+'",
                  "fields":{
                    "summary":"summary",
                    "issuetype":{
                      "iconUrl":"https://veritrans.atlassian.net/images/icons/statuses/generic.png"
                    },
                    "status":{
                      "statusCategory":{
                        "colorName":"yellow",
                        "name":"In Progress"
                      }
                    }
                  }
            }'}.join(",\n") + ']}', 
        headers: {})
  end
end
