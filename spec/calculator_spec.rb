require 'spec_helper'

require 'calculator'

module MockDisplay
  def update(contents)
    @displayed_values << contents
  end

  def display_contents
    @displayed_values.last
  end

  def reset_display_memory
    @displayed_values = [ ]
  end
end

describe Calculator do
  include PocketCalculatorHelper
  include MockDisplay

  subject(:calculator) { Calculator.new(display: self) }

  before(:each) do
    reset_display_memory
  end

  context "just taken out of the box" do
    it "is turned off" do
      expect {
        press_digits 1, 2, 3
      }.to_not change { display_contents }.from(nil)
    end

    it "lets you press any button without anything happening" do
      pending "We're currently cheating by only disabling digits"
    end

    describe "AC" do
      it "turns the calculator on" do
        expect {
          calculator.ac
        }.to change { display_contents }.from(nil).to("0.")
      end
    end
  end

  context "turned on" do
    before(:each) do
      calculator.ac
    end

    describe "typing" do
      example do
        press_digit 1
        expect(display_contents).to be == "1."
      end

      example do
        press_digits 1, 2
        expect(display_contents).to be == "12."
      end

      example do
        press_digits 1, 2, 3, 4, 5, 6, 7, 8, 9, 0

        expect(display_contents).to be == "1234567890."
      end

      example do
        press_digits 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1

        expect(display_contents.length).to be == 11
        expect(display_contents).to be == "1234567890."
      end

      describe "equals" do
        example do
          press_digits 1, 2, 3
          calculator.equals
          press_digits 4, 5, 6
          expect(display_contents).to be == "456."
        end
      end

      describe "addition" do
        example do
          press_digits 1, 2, 3
          calculator.plus
          expect(display_contents).to be == "123."

          press_digit 4
          expect(display_contents).to be == "4."
          press_digits 5, 6
          expect(display_contents).to be == "456."
        end
      end

      describe "subtraction" do
        example do
          press_digits 4, 5, 6
          calculator.minus
          expect(display_contents).to be == "456."

          press_digit 1
          expect(display_contents).to be == "1."
          press_digits 2, 3
          expect(display_contents).to be == "123."
        end
      end

      describe "negative numbers" do
        example do
          press_digits 1, 2, 3
          calculator.plus_minus
          expect(display_contents).to be == "-123."
        end

        example do
          press_digits 1, 2, 3
          calculator.plus_minus
          calculator.plus_minus
          expect(display_contents).to be == "123."
        end

        example do
          press_digits 1, 2, 3
          calculator.plus
          calculator.plus_minus
          expect(display_contents).to be == "-123."
          press_digit 7
          expect(display_contents).to be == "7."
        end
      end

      describe "decimals" do
        example do
          press_digits 1, 2, 3
          calculator.point
          expect(display_contents).to be == "123."
        end

        example do
          press_digits 1, 2, 3
          calculator.point
          press_digits 4, 5
          expect(display_contents).to be == "123.45"
        end

        example do
          press_digits 1, 2, 3
          calculator.point
          press_digits 0, 1, 0
          calculator.equals
          expect(display_contents).to be == "123.01"
        end

        example do
          press_digits 1, 2, 3
          calculator.point
          press_digits 0, 0, 0
          calculator.equals
          expect(display_contents).to be == "123."
        end
      end

      describe "changing your mind about an operation" do
        example do
          press_digits 4, 5, 6
          calculator.plus
          calculator.minus

          press_digits 1, 2, 3
          calculator.equals

          expect(display_contents).to be == "333."
        end
      end

      describe "backspace" do
        example do
          press_digits 1, 2, 3
          calculator.backspace
          expect(display_contents).to be == "12."
        end

        example do
          press_digits 1, 2, 3

          3.times do
            calculator.backspace
          end

          expect(display_contents).to be == "0."
        end

        example do
          press_digits 1, 2, 3

          4.times do
            calculator.backspace
          end

          expect(display_contents).to be == "0."
        end

        example do
          press_digits 1, 2, 3
          calculator.point
          press_digits 4, 5
          calculator.backspace

          expect(display_contents).to be == "123.4"
        end

        example do
          press_digits 1, 2, 3
          calculator.point
          press_digits 4, 5
          calculator.backspace

          expect(display_contents).to be == "123.4"
        end

        example do
          press_digits 1, 2, 3
          calculator.point
          press_digit 4
          calculator.backspace
          calculator.backspace
          press_digit 9

          expect(display_contents).to be == "129."
        end

        example do
          press_digits 1, 2, 3
          calculator.plus
          press_digits 4, 5, 6
          calculator.backspace
          calculator.equals

          expect(display_contents).to be == "168."
        end

        example do
          press_digits 1, 2, 3
          calculator.plus
          calculator.backspace
          calculator.equals

          expect(display_contents).to be == "135."
        end
      end

      describe "clear" do
        example do
          press_digits 1, 2, 3
          calculator.plus
          press_digits 4, 5, 6
          calculator.c

          expect(display_contents).to be == "0."
        end

        example do
          press_digits 1, 2, 3
          calculator.plus
          press_digits 4, 5, 6
          calculator.c
          press_digits 1, 2, 3
          calculator.equals

          expect(display_contents).to be == "246."
        end
      end

      describe "all clear" do
        example do
          press_digits 1, 2, 3
          calculator.plus
          press_digits 4, 5, 6
          calculator.ac

          expect(display_contents).to be == "0."
        end

        example do
          press_digits 1, 2, 3
          calculator.plus
          press_digits 4, 5, 6
          calculator.ac
          press_digits 1, 2, 3
          calculator.equals

          expect(display_contents).to be == "123."
        end
      end
    end

    describe "addition" do
      before(:each) do
        calculator.ac
      end

      example do
        press_digits 1, 2, 3
        calculator.plus
        press_digits 4, 5, 6
        calculator.equals

        expect(display_contents).to be == "579."
      end

      example do
        press_digits 1, 2, 3
        calculator.plus
        press_digits 4, 5, 6
        calculator.plus

        expect(display_contents).to be == "579."

        press_digits 7, 8, 9
        calculator.equals

        expect(display_contents).to be == "1368."
      end

      example do
        press_digits 1, 2, 3
        calculator.plus
        press_digits 4, 5, 6
        calculator.equals
        calculator.plus
        press_digits 7, 8, 9
        calculator.equals

        expect(display_contents).to be == "1368."
      end

      example do
        calculator.plus
        press_digits 1, 2, 3
        calculator.equals

        expect(display_contents).to be == "123."
      end
    end

    describe "subtraction" do
      before(:each) do
        calculator.ac
      end

      example do
        press_digits 4, 5, 6
        calculator.minus
        press_digits 1, 2, 3
        calculator.equals

        expect(display_contents).to be == "333."
      end

      example do
        press_digits 4, 5, 6
        calculator.minus
        press_digits 1, 2, 3
        calculator.minus

        expect(display_contents).to be == "333."

        press_digits 3, 2, 1
        calculator.equals

        expect(display_contents).to be == "12."
      end
    end

    describe "multiplication" do
      example do
        press_digit 5
        calculator.times
        press_digit 6
        calculator.equals

        expect(display_contents).to be == "30."
      end
    end

    describe "division" do
      example do
        press_digits 5, 6
        calculator.divide_by
        press_digit 8
        calculator.equals

        expect(display_contents).to be == "7."
      end
    end

    describe "negative numbers" do
      example do
        press_digits 1, 2, 3
        calculator.plus_minus
        calculator.equals
        expect(display_contents).to be == "-123."
      end

      example do
        press_digits 1, 2, 3
        calculator.plus
        press_digits 6, 7
        calculator.plus_minus
        calculator.equals
        expect(display_contents).to be == "56."
      end

      example do
        press_digits 1, 2, 3
        calculator.plus
        press_digit 6
        calculator.plus_minus
        press_digit 7
        calculator.equals
        expect(display_contents).to be == "56."
      end

      example do
        press_digits 1, 2, 3
        calculator.plus
        calculator.plus_minus
        press_digits 7
        calculator.equals
        expect(display_contents).to be == "130."
      end
    end

    describe "decimal maths" do
      example "addition" do
        press_digits 1, 2
        calculator.point
        press_digits 3, 4

        calculator.plus

        press_digits 5, 6
        calculator.point
        press_digits 7, 8

        calculator.equals

        expect(display_contents).to be == "69.12"
      end

      example "subtraction" do
        press_digits 5, 6
        calculator.point
        press_digits 7, 8

        calculator.minus

        press_digits 1, 2
        calculator.point
        press_digits 3, 4

        calculator.equals

        expect(display_contents).to be == "44.44"
      end

      example "multiplication" do
        press_digits 1, 2
        calculator.point
        press_digits 3, 4

        calculator.times

        press_digits 5, 6
        calculator.point
        press_digits 7, 8

        calculator.equals

        expect(display_contents).to be == "700.6652"
      end

      example "division" do
        press_digits 5, 6
        calculator.point
        press_digits 7, 8

        calculator.divide_by

        press_digits 1, 2
        calculator.point
        press_digits 3, 4

        calculator.equals

        expect(display_contents).to be == "4.601296596"
      end
    end

    describe "memory" do
      describe "adding" do
        example do
          press_digits 1, 2, 3
          calculator.m_plus
          calculator.plus
          press_digits 4, 5, 6
          calculator.ac
          calculator.mr

          expect(display_contents).to be == "123."
        end

        example do
          press_digits 1, 2, 3
          calculator.m_plus
          press_digits 4, 5, 6
          calculator.m_plus
          calculator.mr

          expect(display_contents).to be == "579."
        end

        example do
          press_digits 1, 2
          calculator.m_plus
          calculator.ac
          press_digits 3, 4
          calculator.m_plus
          calculator.ac
          press_digits 4, 5
          calculator.m_plus
          calculator.ac
          calculator.mr

          expect(display_contents).to be == "91."
        end
      end

      describe "subtraction" do
        example do
          press_digits 1, 2, 3
          calculator.m_minus
          calculator.plus
          press_digits 4, 5, 6
          calculator.ac
          calculator.mr

          expect(display_contents).to be == "-123."
        end

        example do
          press_digits 1, 2, 3
          calculator.m_minus
          press_digits 4, 5, 6
          calculator.m_minus
          calculator.mr

          expect(display_contents).to be == "-579."
        end

        example do
          press_digits 1, 2
          calculator.m_minus
          calculator.ac
          press_digits 3, 4
          calculator.m_minus
          calculator.ac
          press_digits 4, 5
          calculator.m_minus
          calculator.ac
          calculator.mr

          expect(display_contents).to be == "-91."
        end
      end

      describe "re-using a number in the display" do
        example do
          press_digits 3, 9
          calculator.m_plus
          calculator.m_plus
          calculator.m_plus
          calculator.m_minus
          calculator.mr

          expect(display_contents).to be == "78."
        end
      end

      describe "clearing" do
        example do
          press_digits 8, 1
          calculator.m_plus
          press_digits 2, 5
          calculator.m_minus

          calculator.mr
          calculator.mc
          expect(display_contents).to be == "56."
          calculator.mr
          expect(display_contents).to be == "0."
        end
      end
    end
  end
end