Feature: Create hotfix of previously rollbacked CR
  In order to easily track what CR that has been rollbacked and getting hotfixes
  As a requestor
  I want to be able to create a hotfix CR that has a reference to the rollbacked CR


  Background:
    Given I am logged in

  Scenario: Trying to create a hotfix of a non-rollbacked CR
    Given I have created a change request
    When I try to access create hotfix method directly
    Then it should be restricted and I am redirected to the change request index

  Scenario: Creating a hotfix for a rollbacked CR
    Given there is a rollbacked CR
    When I visit the rollbacked CR
    And clicked create hotfix button
    Then I will be redirected to a change request new page
    And the rollbacked CR will be referenced
