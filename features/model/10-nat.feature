Feature: Model: Test NAT Functions
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Background:
    Given that I am using embedded test data 'test-model'


  Scenario: Check NAT model
    When I run `./bin/rain nat model test01`
    Then the exit status should be 0
    And the output should match /DNAT\s+tcp\s+1.2.3.4\s+22\s+10.0.31.10\s+22/
    And the output should match /DNAT\s+tcp\s+1.2.3.4\s+80\s+10.0.32.10\s+80/
    And the output should match /SNAT\s+Any\s+10.0.0.0/
    And the output should have 4 lines
