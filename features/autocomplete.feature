@login
Feature: Shows suggestions by using autocomplete in comment field
  In order to easily mention other user
  As a user
  I want to be shown suggestions of users in the comment field when I typed @

  Background:
    Given I am logged in as approver
    And someone has made a change request

  @javascript
  Scenario: Shows autocomplete suggestions
    Given I am in that change request's show page
    When I input @ in the comment field
    Then it should show suggestions that shows all users name
