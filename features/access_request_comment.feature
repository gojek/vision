Feature: Access Request Comment
	As user,
	I want to be able to add comment in AR

	Scenario: Seeing added comment and hiding it
	Given I am logged in
	And an access request with employee name "Gaben Raharjanto"
	And I add "Nice one gaben !" on "Gaben Raharjanto" comment section
	When I visit the access request
	Then I should be able to see "Nice one gaben !"