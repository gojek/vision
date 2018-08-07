@search
Feature: Search access request
  As a user
  I want to search existing AR

Background:
  Given an access request with employee name "Sercy Solry Sunny Spotty"

Scenario: User search change requests using search box
  Given I am logged in
  When I visit page "/access_requests"
  And I search "solry" in search box
  Then I should see access requests with employee name "Sercy Solry Sunny Spotty"
