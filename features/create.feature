Story: Generating a "create" action
  As a developer
  I want to generate a "create" action
  So that I don't have to manually code it

  Scenario: POSTing form parameters
    Given a mounted model
    When I make a POST request with valid form params
    Then a record is created
    And the response redirects to the record show page