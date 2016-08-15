Feature: Quick filters
  In order to easily find change requests with specific conditions
  As a user
  I want to click quick filter buttons that quickly filters change request

  Scenario: Quick filter for all change requests
  Given I am logged in
  And a change request with summary "Heroku Deployment"
  And a change request with summary "Database fix for Dragon"
  When I visit page "/change_requests"
  And I press link "All"
  Then I should be able to see "Showing all change requests"
  And I should be able to see "Heroku Deployment"
  And I should be able to see "Database fix for Dragon"

  Scenario: Quick filter for change requests that need my approvals
  Given I am logged in as approver
  And a change request with summary "Heroku Deployment" that needs my approval
  And a change request with summary "Database fix for Dragon"
  When I visit page "/change_requests"
  And I press link "Need my approvals"
  Then I should be able to see "Showing change requests that needs your approval"
  And I should be able to see "Heroku Deployment"
  And I should not be able to see "Database fix for Dragon"

  Scenario: Quick filter for change requests that relevant to me
  Given I am logged in
  And I created a change request with summary "Heroku Deployment"
  And I am a "collaborator" in a change request with summary "Refactoring Logic in PATO"
  And I am a "implementer" in a change request with summary "Doing something in SNAP"
  And I am a "tester" in a change request with summary "Strengthen security in SNAP"
  And I am a "approver" in a change request with summary "Breakdown Turbo API"
  And a change request with summary "Database fix for Dragon"
  When I visit page "/change_requests"
  And I press link "Relevant to me"
  Then I should be able to see "Showing change requests that is relevant to you"
  And I should be able to see "Heroku Deployment"
  And I should be able to see "Refactoring Logic in PATO"
  And I should be able to see "Doing something in SNAP"
  And I should be able to see "Strengthen security in SNAP"
  And I should be able to see "Breakdown Turbo API"
  And I should not be able to see "Database fix for Dragon"
