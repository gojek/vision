Feature: Access Request Approved Status Bug Fix
	In order to easily monitor approval status
	As a user
	I want to see approval comment and approval time correctly
	I dont want the AR approval to be resetted once I edit the AR

	Scenario: Approval Comment is Shown Correctly
	Given I am logged in
	And an access request with employee name "Harits Arrazi"
	And an access request approved comment "Give Him Access!" with employee name "Harits Arrazi"
	And an access request approved comment "Ok, Cool!" with employee name "Harits Arrazi"
	When I visit access request with employee name "Harits Arrazi"
	Then the page should have "Give Him Access!" on some tag
	And the page should have "Ok, Cool!" on some tag

	Scenario: Approval Time is Shown Correctly
	Given I am logged in
	And an access request with employee name "Saeful Ramadhan" that has been approved on "2018-07-31 07:32" and "2018-07-31 10:35"
	And an access request approval on "2018-07-31 07:32" with employee name "Saeful Ramadhan"
	And an access request approval on "2018-07-31 10:35" with employee name "Saeful Ramadhan"
	When I visit access request with employee name "Saeful Ramadhan"
	Then I should be able to see "Approved on July 31, 2018 07:32"
	And I should be able to see "Approved on July 31, 2018 10:35"

	Scenario: Approvel won't be reset once we edit the AR
	Given I am logged in
	And an access request with employee name "Zulfahmi Ibnu Habibi" that has been approved on "2018-07-31 07:32" and "2018-07-31 10:35"
	When I update access request with employee name "Zulfahmi Ibnu Habibi"
	Then I should be able to see "Approved on July 31, 2018 07:32"
	And I should be able to see "Approved on July 31, 2018 10:35"