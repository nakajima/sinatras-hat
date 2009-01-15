Story: Custom format handlers
  As a developer
  I want to provide custom format handlers
  So that I expose data in more interesting ways

  Scenario: A valid request with a custom format
    Given a model that has a record
    And I mount the model
    And specify a custom 'ruby' formatter
    When I make a GET request for that record using the 'ruby' format
    Then the status code is 200
    And the body is the custom serialized record
  
  Scenario: A request with a known format specified
    Given a mounted model
    And the model has some records
    When Make a GET request to the index using the 'ruby' format
    Then the status code is 200
    And the result should be custom serialized