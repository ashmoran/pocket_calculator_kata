Feature: Entering decimals
  As with entering integers, here we only care that the
  display is correct.

  Background:
    Given I have a pocket calculator
    And it is turned on

  Scenario: Pressing "." after a few digits
    When I press "1 2 3 ."
    Then the display shows "123."

  Scenario: Entering decimal places
    When I press "1 2 3 . 4 5"
    Then the display shows "123.45"

  Scenario: Truncating trailing decimal zeros after equals
    When I press "1 2 3 . 0 1 0 ="
    Then the display shows "123.01"

  Scenario Outline: Truncating trailing decimal zeros after an operator
    When I press "1 2 3 . 0 1 0 <operator>"
    Then the display shows "123.01"

    Examples:
      | operator |
      | +        |
      | -        |
      | *        |
      | /        |

  Scenario: Truncating trailing decimal zeros from an integer
    When I press "1 2 3 . 0 0 0 ="
    Then the display shows "123."

  Scenario Outline: Truncating trailing decimal zeros from an integer after an operator
    When I press "1 2 3 . 0 0 0 <operator>"
    Then the display shows "123."

    Examples:
      | operator |
      | +        |
      | -        |
      | *        |
      | /        |
