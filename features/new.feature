Feature: Generating a "new" action
  As a developer
  I want to generate a "new" action
  So that I don't have to manually code it

  Scenario: Getting the new action without a format
    Given a mounted model
    When I get the new page for that record
    Then I should see "So, you want to create a new Person?"
  
  Scenario: Getting the new action with a valid format
    Given a mounted model
    When I get the new action with a valid format
    Then the body is a serialized new record

  Scenario: Getting the new action with an invalid format
    Given a mounted model
    When I get the new action with an invalid format
    Then the status code is 406
    And the body is empty