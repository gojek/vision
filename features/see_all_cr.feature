Feature: See all CR
  In order to know what changes are being submitted / deployed
  As a user
  I want to be able to see all change requests


  Background:
    Given I am logged in

  Scenario: See all change requests
    Given a change request with summary "Heroku Deployment"
    When I visit page "/change_requests"
    Then I should be able to see "Heroku Deployment"
    And the page should have "Show" link
    And the page should have "Duplicate" link
    And the page should not have "Edit" link
    And the page should not have "Delete" link
