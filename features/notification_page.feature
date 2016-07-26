@login
Feature: Notification page
  In order to view my notifications
  As a user
  I want to visit a notification page


  Background:
    Given I am logged in


  Scenario: View change request notifications
    Given I have any change request notifications
    When I click the change request notifications button
    Then I should be redirected to the notification page
    And I could see the change request notifications

  Scenario: View incident report notifications
    Given I have any incident report notifications
    When I click the incident report notifications button
    Then I should be redirected to the notification page
    And I could see the incident report notifications

  Scenario: Show nothing to display if user have no change request notifications
    Given I have no change request notifications
    When I click the change request notifications button
    Then I should be redirected to the notification page
    And I should see Nothing to display here! text

  Scenario: Show nothing to display if user have no incident report notifications
    Given I have no incident report notifications
    When I click the incident report notifications button
    Then I should be redirected to the notification page
    And I should see Nothing to display here! text
