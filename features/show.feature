Story: Show action
  As a developer
  I want to mount a show action
  So that I don't have to manually code it

  Scenario: A valid request without a format
    Given a model that has a record
    And I mount the model
    When I get the show page for that record
    Then the show.erb template is rendered
  
  Scenario: An invalid request without a format
    Given a model that does not have a record
    And I mount the model
    When I get the show page for the invalid record
    Then the status code is 404
    And the body is empty