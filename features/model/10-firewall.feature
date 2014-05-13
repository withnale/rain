Feature: Model: Test Firewall Functions
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Background:
    Given that I am using embedded test data 'test-model'


  Scenario: Check Firewall model
    When I run `./bin/rain firewall model test01`
    Then the exit status should be 0
    And the output should match /allow\s+tcp\s+external.*any\s+1.2.3.4\s+22\s+any-22/
    And the output should match /allow\s+tcp\s+external.*any\s+1.2.3.4\s+80\s+any-80/
    And the output should match /allow\s+any\s+internal.*any\s+external\s+any\s+internal-all-out/
    And the output should match /allow\s+any\s+internal.*any\s+internal\s+any\s+internal-to-internal/
    And the output should have 5 lines
