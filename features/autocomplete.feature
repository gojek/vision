@login
Feature: Shows suggestions by using autocomplete in comment field
  In order to easily mention other user
  As a user
  I want to be shown suggestions of users in the comment field when I typed @

  Background:
    Given I am logged in as approver
    
  @javascript
  Scenario: Shows autocomplete suggestions
    Given a change request with summary "Heroku Deployment"
    When I visit page "/change_requests"
    And I press link "Show"
    And I input "@" in field "comment"
    Then it should show suggestions that shows all users name
