Feature: Testdata: Envs, Zones and Models
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Background:
    Given that I am using embedded test data 'test-model'


  Scenario: List of environments
    When I run `./bin/rain env list`
    Then the exit status should be 0
    And the output should contain "test01"
    And the output should contain "test02"


  Scenario Outline: Check for valid environment
    Given the input "<arg1> --help"
    When I run `./bin/rain <arg1> test01`
    Then the exit status should be 0
  Examples:
    | arg1           |
    | env model      |
    | server model   |
    | nat model      |
    | network model  |
    | firewall model |


  Scenario Outline: Detect unknown environment
    When I run `./bin/rain <arg1> unknown-env`
    Then the exit status should not be 0
    And the output should contain "not recognised"
  Examples:
    | arg1           |
    | env model      |
    | server model   |
    | nat model      |
    | network model  |
    | firewall model |


  Scenario Outline: Detect unknown model
    When I run `./bin/rain <arg1> test03`
    Then the exit status should not be 0
    And the output should contain "cannot be found"
  Examples:
    | arg1           |
    | env model      |
    | server model   |
    | nat model      |
    | network model  |
    | firewall model |

