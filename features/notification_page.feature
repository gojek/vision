Feature: Notification page
  In order to view my notifications
  As a user
  I want to visit a notification page to view my notifications


  Background:
    Given I am logged in

  Scenario: View change request notifications
    Given I have "Deploy feature to heroku" change request notifications
    When I press link "Change Request Notifications"
    Then I should be redirected to the notification page
    And the "Change Request" section should be active
    And the "New" tab should be active
    And I should be able to see "Deploy feature to heroku"

  Scenario: View Incident Report notifications
    Given I have "Database cluster error" incident report notifications
    When I press link "Incident Report Notifications"
    Then I should be redirected to the notification page
    And the "Incident Report" section should be active
    And the "New" tab should be active
    And I should be able to see "Database cluster error"

  Scenario: Show nothing to display if user have no change request notifications
    Given I have no change request notifications
    When I press link "Change Request Notifications"
    Then I should be redirected to the notification page
    And I should be able to see "Nothing to display here!"

  Scenario: Show nothing to display if user have no incident report notifications
    Given I have no incident report notifications
    When I press link "Incident Report Notifications"
    Then I should be redirected to the notification page
    And I should be able to see "Nothing to display here!"
