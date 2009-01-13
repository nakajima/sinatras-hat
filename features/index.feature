Story: Index Action
  As a developer
  I want to mount an index action
  So that I don't have to manually code it

  Scenario: A request without a format specified
    Given a model that has some records
    And I mount the model
    When I get the index without a format
    Then the index.erb template should be rendered

  Scenario: A request with a known format specified
    Given a model that has some records
    And I mount the model
    When I get the index with a known format
    Then the result should be serialized

  Scenario: A request with an unknown format
    Given a model that has some records
    And I mount the model
    When I get the index with an unknown format
    Then the result should render a good error message
    And the status code should reflect the unknown format