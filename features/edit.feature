Story: Generating an "edit" action
  As a developer
  I want to generate an "edit" action
  So that I don't have to manually code it

  Scenario: Getting the edit page for a record
    Given a model that has a record
    And I mount the model
    When I get the edit page for that record
    Then the edit.erb template is rendered

  Scenario: Getting the edit page for a non-existent record
    Given a model that has a record
    And I mount the model
    When I get the edit page for a non-existent record
    Then the status code is 404
    And the body is empty