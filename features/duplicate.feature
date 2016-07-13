@login
Feature: Duplicate Change request
  In order to easily create a duplicate of a failed change request
  As a user
  I want to click a duplicate button that would create a new change request with the previous attributes already filled in

  Background:
  Given I am logged in
  And I have created a change request

  @javascript
  Scenario:
  Given I am in the change requests index page
  When I click on the duplicate link
  Then I should be redirected to a new change request page
  And all field should be filled in except implementation and grace period dates
