Feature: Can not add approver on update bug fix
	When we update the access request and add more approver
	We can not see the new approver on the list of approver
	As a requestor
	I want to add approver when I update access request

	Scenario: Adding approver on access request update
	Given I am logged in
	And I made an access request with employee name "Jodhi P"
	When I add approver on the access request with approver name "Wirane Gara"
	When I visit the access request
	Then I should be able to see "Wirane Gara"