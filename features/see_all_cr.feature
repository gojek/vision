@login
Feature: See all CR
  In order to know what changes are being submitted / deployed
  As a user
  I want to be able to see all change requests


  Background:
    Given I am logged in

  Scenario: See all change requests
    Given another user has made a change request
    When I visit the change request index page
    Then I should be able to see that change request
