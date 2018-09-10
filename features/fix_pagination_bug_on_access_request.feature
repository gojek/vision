Feature: Fix pagination bug on access request
	Currently we cannot visit the second, third, etc page on list of access request
	As a user
	I want to see every access request on vision

	Background:
	Given there are 25 access request

	Scenario:
	Given I am logged in
	When I visit page "access_requests"
	Then the page should have "pagination" on some tag