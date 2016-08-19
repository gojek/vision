@javascript
Feature: Scheduling UI improvement
  In order to easily schedule and track current change requests status
  As an associated user
  I want to be shown scheduling status and options

  Background:
    Given I am logged in


  Scenario: Seeing scheduling status
    Given a change request with summary "Heroku Deployment"
    When I visit page "/change_requests"
    And I press link "Show"
    Then I should be able to see "Heroku Deployment"
    And I should be able to see "Submitted"
    And I should not be able to see "Next Action"


  Scenario: Seeing the scheduling options in next action button
    Given I am a "collaborator" in a change request with summary "Heroku Deployment"
    When I visit page "/change_requests"
    And I press link "Show"
    And I press button "Next Action"
    Then I should be able to see "Heroku Deployment"
    And I should be able to see "Schedule Change Request"
    And I should be able to see "Close Change Request"
    And I should be able to see "Reject Change Request"

  Scenario: Scheduling a submitted change request
    Given I am a "collaborator" in a change request with summary "Heroku Deployment" that has been approved
    When I visit page "/change_requests"
    And I press link "Show"
    And I press button "Next Action"
    And I press link "Schedule Change Request"
    And I input "reasoning" in field "change_request_status_reason"
    And I press "Update Change Request Status to Schedule" submit button
    Then I should be able to see "Heroku Deployment"
    And I should be able to see "Scheduled"
