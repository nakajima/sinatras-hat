Feature: Generating an "index" action for a child resource
  As a developer
  I want to generate an "index" action for a child resource
  So that I don't have to manually code it

  Scenario: Getting the template
    Given a model that has a record
    And the record has children
    And I mount the model
    When Make a GET request to the nested index without a format
    Then the status code is 200
    Then I should see "The nested view!"

  Scenario: Requesting a valid format
    Given a model that has a record
    And the record has children
    And I mount the model
    When Make a GET request to the nested index with a valid format
    Then the status code is 200
    Then the body is the serialized list of children