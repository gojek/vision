@search
Feature: Search change request
  As an IT Ops
  I want to be able to search the Change Requests based on keywords

Background:
  Given a change request with summary "Upgrade vision to 2.0"

Scenario: User search change requests using search box
  Given I am logged in
  When I visit page "/change_requests"
  And I search "vision" in search box
  Then I should see change requests with summary "Upgrade vision to 2.0"
