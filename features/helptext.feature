Feature: Valid Help Text
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself


  Scenario Outline: Helptext for top-level commands when --help specified
    Given the input "<arg1> --help"
    When I run `./bin/rain <arg1> --help`
    Then the exit status should be 0
    And the output should contain "Usage: rain <arg1>"
    And the output should contain "Show Help"
    And the output should not contain "translation missing"
  Examples:
    | arg1     | location |
    | env      | env      |
    | zone     | zone     |
    | server   | server   |
    | image    | image    |
    | network  | network  |
    | firewall | firewall |


  @works
  Scenario Outline: Helptext for sub-commands when --help specified
    Given the input "<arg1> --help"
    When I run `./bin/rain <arg1> --help`
    Then the exit status should be 0
    And the output should contain "Usage: rain <arg1>"
    And the output should contain "Show Help"
    And the output should not contain "translation missing"
  Examples:
    | arg1            |
    | env list        |
    | env model       |
    | env vars        |
    | env create      |
    | env config      |
    | env show        |

    | firewall show   |
    | firewall diff   |
    | firewall model  |
    | firewall create |

    | network show    |
    | network diff    |
    | network model   |
    | network create  |

    | nat show        |
    | nat diff        |
    | nat model       |
    | nat create      |

    | server show     |
    | server diff     |
    | server model    |
    | server create   |
    | server action   |
    | server poweron  |
    | server poweroff |
    | server delete   |

    | image show      |
    | image upload    |

    | zone list       |









