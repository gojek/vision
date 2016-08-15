Feature: Duplicate Change request
  In order to easily create a duplicate of a failed change request
  As a user
  I want to click a duplicate button that would create a new change request with the previous attributes already filled in

  Background:
  Given a user named "Lia Sadita"
  And I am logged in as "Lia Sadita"
  And a change request with summary "Heroku Deployment"

  @javascript
  Scenario: When I duplicate a change request, it should copy the change requests previous data
  Given I am in page "/change_requests"
  When I press link "Duplicate"
  Then I should be redirected to a new change request page
  And the "requestor name" field should be filled in with "Lia Sadita"
  And the "change summary" field should be filled in with "Heroku Deployment"

  @javascript
  Scenario: When I duplicate a change request, it should leave schedule change date, planned completion, grace period starts, and grace period end fields empty
  Given I am in page "/change_requests"
  When I press link "Duplicate"
  Then I should be redirected to a new change request page
  And I press link "Implementation"
  And the "schedule change date" field should be empty
  And the "planned completion" field should be empty
  And the "grace period starts" field should be empty
  And the "grace period end" field should be empty
