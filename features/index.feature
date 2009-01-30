Feature: Generating an "index" action
  As a developer
  I want to generate an "index" action
  So that I don't have to manually code it

  Scenario: A request without a format specified
    Given a mounted model
    And the model has some records
    When Make a GET request to the index without a format
    Then I should see "The people:"

  Scenario: A request with a known format specified
    Given a mounted model
    And the model has some records
    When Make a GET request to the index with a known format
    Then the result should be serialized

  Scenario: A request with an unknown format
    Given a mounted model
    And the model has some records
    When I make a GET request to the index with an unknown format
    Then the body is empty
    And the status code is 406