Story: Update action
  As a developer
  I want to mount an update action
  So that I don't have to manually code it

  Scenario: A PUT request with Railsy form params and no format
    Given a model that has a record
    And I mount the model
    When I make a put request with valid form params
    Then the record is updated
    And the response redirects to the record show page
  
  Scenario: A PUT request with format serialized attributes
    Given a model that has a record
    And I mount the model
    When I make a put request with format serialized attributes
    Then the record is updated
    And the body is the serialized record