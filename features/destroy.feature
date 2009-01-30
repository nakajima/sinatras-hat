Feature: Generating a "destroy" action
  As a developer
  I want to generate a "destroy" action
  So that I don't have to manually code it

  Scenario: Deleting a record
    Given a model that has a record
    And I mount the model
    When I make a DELETE request to the path for that record
    Then the record gets destroyed
    And I am redirected to the index action
  
  Scenario: Trying to delete a non-existent record
    Given a model that does not have a record
    And I mount the model
    When I make a DELETE request to a path for a non-existent record
    Then the status code is 404
    And the body is empty