Feature: Business Justification
	As requestor
	I want to have business justification field when I create Access Request

	Scenario: Seeing business justification
	Given I am logged in
	And an access request with employee name "Rani" with "Describing Engineering" as business justification
	When I visit access request with employee name "Rani"
	Then I should be able to see "Describing Engineering"
