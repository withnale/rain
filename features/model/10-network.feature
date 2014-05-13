Feature: Model: Test Network Functions
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Background:
    Given that I am using embedded test data 'test-model'



  Scenario: Check network model
    Given the input "<arg1> --help"
    When I run `./bin/rain network model test01`
    Then the exit status should be 0
    And print the output
    And the output should match /admin.*10.0.31.1/
    And the output should match /web.*10.0.32.1/
    And the output should match /db.*10.0.33.1/
    And the output should have 5 lines

