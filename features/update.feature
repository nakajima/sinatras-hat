Story: Generating an "update" action
  As a developer
  I want to generate an "update" action
  So that I don't have to manually code it

  Scenario: A PUT request with valid form params and no format
    Given a model that has a record
    And I mount the model
    When I make a put request with valid form params
    Then the record is updated
    And the response redirects to the record show page

  Scenario: A PUT request with invalid form params and no format
    Given a model that has a record
    And I mount the model
    When I make a PUT request with invalid form params
    Then the edit.erb template is rendered
    And the record is not updated

  Scenario: Trying to update a record that does not exist
    Given a model that does not have a record
    And I mount the model
    When I make a put request with valid form params
    Then the status code is 404
    And the body is empty
