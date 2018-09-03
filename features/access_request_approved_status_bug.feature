Feature: Access Request Approved Status Bug Fix
	In order to easily monitor approval status
	As a user
	I want to see approval comment and approval time correctly
	I dont want the AR approval to be resetted once I edit the AR

	Scenario: Approval Comment is Shown Correctly
	Given I am logged in
	And an access request with employee name "Harits Arrazi"
	And that access request has approved comment "Give Him Access!"
	And that access request has approved comment "Ok, Cool!"
	When I visit the access request
	Then the page should have "Give Him Access!" on some tag
	And the page should have "Ok, Cool!" on some tag

	Scenario: Approval Time is Shown Correctly
	Given I am logged in
	And an access request with employee name "Saeful Ramadhan"
	And that access request has been approved on "2018-07-31 07:32"
	And that access request has been approved on "2018-07-31 10:35"
	When I visit the access request
	Then I should be able to see "Approved on July 31, 2018 07:32"
	And I should be able to see "Approved on July 31, 2018 10:35"

	Scenario: Approval won't be reset once we edit the AR
	Given I am logged in
	And an access request with employee name "Zulfahmi Ibnu Habibi"
	And that access request has been approved on "2018-07-31 07:32"
	And that access request has been approved on "2018-07-31 10:35"
	When I update the access request
	Then I should be able to see "Approved on July 31, 2018 07:32"
	And I should be able to see "Approved on July 31, 2018 10:35"