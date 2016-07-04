@login
Feature: Clear change request and incident report notifications
  In order to tidy up my dashboard
  As a user
  I want to click the button to clear all notifications


  Background:
    Given I am logged in as approver

  Scenario: Clear notifications when button is clicked
    Given I have any change request / incident report notifications
    When I click the clear notification button
    Then all notifications should be removed
