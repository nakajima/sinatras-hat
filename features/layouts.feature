Feature: Rendering view layouts
  In order to reduce duplication
  As a developer
  I want use common layouts
  
  Scenario: Rendering the default layout
    Given a mounted model
    And the model has some records
    When Make a GET request to the index without a format
    Then I should see "TEH LAYOUTZ"
    And the index.erb template should be rendered
    
