Feature: Limiting the amount of actions defined
  As a developer
  I want to generate specify the actions that get generated
  So that unnecessary actions don't get defined

  Scenario: Calling only in the block
    Given a model that has a record
    And I mount the model for only the :index action
    When Make a GET request to the index without a format
    Then the index.erb template should be rendered
    
    When I get the show page for that record
    Then the status code is 404
