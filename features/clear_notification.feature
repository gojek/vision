Feature: Clear change request and incident report notifications
  In order to tidy up my dashboard
  As a user
  I want to click the button to clear all notifications


  Background:
    Given I am logged in

  Scenario: Clear notifications when button is clicked
    Given I have "Deploy feature to heroku" change request notifications
    And I have "Database cluster error" incident report notifications
    When I press link "Clear Notification"
    Then all notifications should be removed
