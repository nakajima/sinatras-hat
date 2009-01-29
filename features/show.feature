Story: Generating a "show" action
  As a developer
  I want to generate a "show" action
  So that I don't have to manually code it

  Scenario: A valid request without a format
    Given a model that has a record
    And I mount the model
    When I get the show page for that record
    Then I should see "The person:"
  
  Scenario: Trying to show a record that does not exist
    Given a model that does not have a record
    And I mount the model
    When I get the show page for the non-existent record
    Then the status code is 404
    And the body is empty
  
  Scenario: A valid request with a built-in format
    Given a model that has a record
    And I mount the model
    When I make a GET request for that record using the 'xml' format
    Then the status code is 200
    And the body is the serialized record
    
  Scenario: An invalid request with a format
    Given a model that does not have a record
    And I mount the model
    When I get the GET request for a non-existent record with a format
    Then the status code is 404
    And the body is empty