Feature: Access Request Metabase access
	As user, i want to add metabase in other access field in Access request

	Scenario: Metabase access is shown correctly
	Given I am logged in
	And an access request with employee name "Wirane Gara"
	And that access request had metabase access checked as "true"
	When I visit the access request
	Then the page should have checked input "access_request_metabase"