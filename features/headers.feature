Feature: Setting appropriate headers
  In order to understand more about a response
  As a developer
  I want Sinatra's Hat to set useful headers
  
  Scenario: Setting the last_modified for show
    Given a model that has a record
    And I mount the model
    When I get the show page for that record
    Then "Last-Modified" should be the record "updated_at" time
  
  Scenario: Setting the last_modified for index
    Given a model that has a record
    And I mount the model
    When Make a GET request to the index without a format
    Then "Last-Modified" should be the record "updated_at" time
