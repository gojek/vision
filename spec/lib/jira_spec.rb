require 'spec_helper'
require 'jira'

describe Jira do
  describe 'generate jira html object' do
    let(:jira) {Jira.new}
    let(:html) {
                "<span class='jira-button'>" \
                "  <a href='https://veritrans.atlassian.net/browse/TEST-123' target='_blank' data-toggle='popover' title='Summary' data-content='summary'><img class='icon' src='https://veritrans.atlassian.net/images/icons/statuses/generic.png'> TEST-123 </a>" \
                "  <span class='jira-yellow'>In Progress</span>" \
                "</span>" \
                }

    it 'mention jira in change_request' do
      jira_change_request = FactoryGirl.create(:jira_change_request)
      jira.jiraize_cr(jira_change_request)

      expect(assigns(:change_request).net).to eq html
      expect(assigns(:change_request).os).to eq html
      expect(assigns(:change_request).db).to eq html
      expect(assigns(:change_request).analysis).to eq html
      expect(assigns(:change_request).impact).to eq html
      expect(assigns(:change_request).solution).to eq html
    end

    it 'mention jira in incident_report' do
      # stub_request(:get, "https://veritrans.atlassian.net/rest/api/2/search?fields=summary,status,issuetype&jql=issueKey=TEST-123")
      # .to_return(
      #   status: 200, 
      #   body: '{
      #   "issues":[{
      #     "attrs":{
      #       "key":"TEST-123", 
      #       "fields":{
      #         "summary":"summary", 
      #         "issuetype":{
      #           "iconUrl":"https://veritrans.atlassian.net/images/icons/issuetypes/story.svg"
      #         }, 
      #         "status":{
      #           "statusCategory":{
      #             "colorName":"green", 
      #             "name":"Done"
      #           }
      #         }
      #       }
      #     }
      #   }]}', 
      #   headers: {})

      stub_request(:get, "https://veritrans.atlassian.net/rest/api/2/search?fields=summary,status,issuetype&jql=issueKey=TEST-123")
      .to_return(
        status: 200, 
        body: '{
        "issues":[{
          "id":"1234",
          "key":"TEST-123",
          "fields":{
            "summary":"summary",
            "issuetype":{
              "iconUrl":"https://veritrans.atlassian.net/images/icons/issuetypes/story.svg"
            },
            "status":{
              "statusCategory":{
                "colorName":"yellow",
                "name":"In Progress"
              }
            }
          }
        }]}', 
        headers: {})

      jira_incident_report = FactoryGirl.create(:jira_incident_report)
      jira.jiraize_ir(jira_incident_report.action_item)

      expect(assigns(:action_item).net).to eq html
    end
  end
end