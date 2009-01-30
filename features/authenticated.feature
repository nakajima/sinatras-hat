Feature: Protected actions
  As a developer
  I want to protect certain actions
  So that I maintain privacy of my app

  Scenario: A request to a protected action
    Given a model that has a record
    And I mount the model protecing the show action
    When I make a GET request for that record
    Then the status code is 401
    When Make a GET request to the index without a format
    Then the status code is 200