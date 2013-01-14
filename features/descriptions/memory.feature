Feature: Memory
  Memory lets us accumulate an answer in stages and is persistent
  even if you press AC to reset the calculator.

  Background:
    Given I have a pocket calculator
    And it is turned on

  # Memory add

  Scenario: Adding one number
    When I press "1 2 3 M+"
    Then the display shows "123."
    When I press "AC MR"
    Then the display shows "123."

  Scenario: Adding two numbers
    When I press "1 2 3 M+ 4 5 6 M+"
    Then the display shows "456."
    When I press "MR"
    Then the display shows "579."

  # Memory subtract

  Scenario: Subtracting one number
    We assume we already have M+, otherwise we'd need
    to use a negative number to test this.

    When I press "1 0 0 0 M+ AC"
    Then the display shows "0."
    When I press "1 2 3 M-"
    Then the display shows "123."
    When I press "MR"
    Then the display shows "877."

  Scenario: Subtracting one number
    We assume we already have M+, otherwise we'd need
    to use a negative number to test this.

    When I press "1 0 0 0 M+ AC"
    Then the display shows "0."
    When I press "1 2 3 M-"
    Then the display shows "123."
    When I press "MR"
    Then the display shows "877."

  # Mid-calculation

  Scenario: Adding to the memory mid-calculation
    If you press M+ while you're half-way through a calculation,
    the calculator will complete the current calculation and add
    it to the memory. It works similarly to "chaining additions"
    from the the integer maths feature.

    When I press "1 2 3 M+ AC 4 5 6 + 7 8 9 M+"
    Then the display shows "1245."
    When I press "MR"
    Then the display shows "1368."

  Scenario: Subtracting from the memory mid-calculation
    This works similarly to the scenario above, except that
    the calculation in progress is subtracted rather than
    added.

    When I press "7 8 9 M+ AC 4 5 6 + 1 2 3 M-"
    Then the display shows "579."
    When I press "MR"
    Then the display shows "210."