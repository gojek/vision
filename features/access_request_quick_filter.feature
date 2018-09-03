Feature: Access Request Quick filters
  In order to easily find access requests with specific conditions
  As a user
  I want to click quick filter buttons that quickly filters access request

  Scenario: Quick filter for all access requests
  Given I am logged in
  And an access request with employee name "Adi Rizka"
  And an access request with employee name "Muhammad Wiranegara Girinata"
  When I visit page "/access_requests"
  And I press link "All"
  Then I should be able to see "Showing all access requests"
  And I should be able to see "Adi Rizka"
  And I should be able to see "Muhammad Wiranegara Girinata"

  Scenario: Quick filter for access requests that need my approvals
  Given I am logged in as approver
  And an access request with employee name "Jodhi Lesmana Putra" that needs my approval
  And an access request with employee name "Muhammad Wiranegara Girinata"
  When I visit page "/access_requests"
  And I press link "Need my approvals"
  Then I should be able to see "Showing access requests that needs your approval"
  And I should be able to see "Jodhi Lesmana Putra"
  And I should not be able to see "Muhammad Wiranegara Girinata"