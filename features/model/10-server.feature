Feature: Model: Test Server Functions
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Background:
    Given that I am using embedded test data 'test-model'


  Scenario: Check Server model
    When I run `./bin/rain server model test01`
    Then the exit status should be 0
    And the output should match /app-01.test01\s+base\s+2048\s+1\s+web\s+10.0.32.20/
    And the output should match /jump.test01\s+base\s+2048\s+1\s+admin\s+10.0.31.10/
    And the output should match /web-01.test01\s+base\s+2048\s+1\s+web\s+10.0.32.10/
    And the output should have 4 lines
