Feature: Create hotfix of previously rollbacked CR
  In order to easily track what CR that has been rollbacked and getting hotfixes
  As a requestor
  I want to be able to create a hotfix CR that has a reference to the rollbacked CR


  Background:
    Given I am logged in

  Scenario: Trying to create a hotfix of a non-rollbacked CR
    Given I have created a change request with summary "Heroku Deployment"
    When I visit change request with change summary "Heroku Deployment"
    Then I should be able to see "Heroku Deployment"
    And the page should not have "Create Hotfix" link

  Scenario: Creating a hotfix for a rollbacked CR
    Given there is a "rollbacked" change request with summary "Heroku Deployment"
    When I visit change request with change summary "Heroku Deployment"
    And I press link "Create Hotfix"
    Then I should be redirected to a change request new page
    And the rollbacked change request should be referenced

  Scenario: Seeing hotfixes for my rollbacked change request
    Given there is a "rollbacked" change request with summary "Heroku Deployment"
    And a hotfix has been made for that rollbacked change request with summary "Fix New Feature for Heroku Deployment"
    When I visit change request with change summary "Heroku Deployment"
    Then I should be able to see "Hotfixes"
    And I should be able to see "Fix New Feature for Heroku Deployment"
