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
    describe "AC" do
      it "turns the calculator on (we don't actually care what happens when it's off)" do
        expect {
          press :ac
        }.to change { display_contents }.from(nil).to("0.")
      end
    end
  end

  context "turned on" do
    before(:each) do
      press :ac
    end

    describe "typing" do
      example do
        press 1
        expect(display_contents).to be == "1."
      end

      example do
        press 1, 2
        expect(display_contents).to be == "12."
      end

      example "maximum length" do
        press 1, 2, 3, 4, 5, 6, 7, 8, 9, 0

        expect(display_contents).to be == "1234567890."
      end

      example "over maximum length" do
        press 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1

        expect(display_contents.length).to be == 11
        expect(display_contents).to be == "1234567890."
      end

      describe "equals" do
        example do
          press 1, 2, 3, :eq
          expect(display_contents).to be == "123."

          press 4
          expect(display_contents).to be == "4."
          press 5, 6
          expect(display_contents).to be == "456."
        end
      end

      describe "addition" do
        example do
          press 1, 2, 3, :+
          expect(display_contents).to be == "123."

          press 4
          expect(display_contents).to be == "4."
          press 5, 6
          expect(display_contents).to be == "456."
        end
      end

      describe "subtraction" do
        example do
          press 4, 5, 6, :-
          expect(display_contents).to be == "456."

          press 1
          expect(display_contents).to be == "1."
          press 2, 3
          expect(display_contents).to be == "123."
        end
      end

      describe "negative numbers" do
        example do
          press 1, 2, 3, :plus_minus
          expect(display_contents).to be == "-123."
        end

        example do
          press 1, 2, 3, :plus_minus, :plus_minus
          expect(display_contents).to be == "123."
        end

        example do
          press 1, 2, 3, :+, :plus_minus
          expect(display_contents).to be == "-123."
          press 7
          expect(display_contents).to be == "7."
        end
      end

      describe "decimals" do
        example do
          press 1, 2, 3, :point
          expect(display_contents).to be == "123."
        end

        example do
          press 1, 2, 3, :point, 4, 5
          expect(display_contents).to be == "123.45"
        end

        example do
          press 1, 2, 3, :point, 0, 1, 0, :eq
          expect(display_contents).to be == "123.01"
        end

        example do
          press 1, 2, 3, :point, 0, 0, 0, :eq
          expect(display_contents).to be == "123."
        end
      end

      describe "changing your mind about an operation" do
        example do
          press 4, 5, 6, :+, :-, 1, 2, 3, :eq
          expect(display_contents).to be == "333."
        end
      end

      describe "backspace" do
        example do
          press 1, 2, 3, :backspace
          expect(display_contents).to be == "12."
        end

        example do
          press 1, 2, 3, :backspace, :backspace, :backspace
          expect(display_contents).to be == "0."
        end

        example do
          press 1, 2, 3, :backspace, :backspace, :backspace, :backspace
          expect(display_contents).to be == "0."
        end

        example do
          press 1, 2, 3, :point, 4, 5, :backspace
          expect(display_contents).to be == "123.4"
        end

        example do
          press 1, 2, 3, :point, 4, 5, :backspace
          expect(display_contents).to be == "123.4"
        end

        example do
          press 1, 2, 3, :point, 4, :backspace, :backspace, 9
          expect(display_contents).to be == "129."
        end

        example do
          press 1, 2, 3, :+, 4, 5, 6, :backspace, :eq
          expect(display_contents).to be == "168."
        end

        example do
          press 1, 2, 3, :+, :backspace, :eq
          expect(display_contents).to be == "135."
        end
      end

      describe "clear" do
        example do
          press 1, 2, 3, :+, 4, 5, 6, :c
          expect(display_contents).to be == "0."
        end

        example do
          press 1, 2, 3, :+, 4, 5, 6, :c,
                1, 2, 3, :eq
          expect(display_contents).to be == "246."
        end
      end

      describe "all clear" do
        example do
          press 1, 2, 3, :+, 4, 5, 6, :ac
          expect(display_contents).to be == "0."
        end

        example do
          press 1, 2, 3, :+, 4, 5, 6, :ac,
                1, 2, 3, :eq
          expect(display_contents).to be == "123."
        end
      end
    end

    describe "addition" do
      example do
        press 1, 2, 3, :+, 4, 5, 6, :eq
        expect(display_contents).to be == "579."
      end

      example do
        press 1, 2, 3, :+, 4, 5, 6, :+
        expect(display_contents).to be == "579."

        press 7, 8, 9, :eq
        expect(display_contents).to be == "1368."
      end

      example do
        press 1, 2, 3, :+, 4, 5, 6, :eq,
              :+, 7, 8, 9, :eq
        expect(display_contents).to be == "1368."
      end

      example do
        press :+, 1, 2, 3, :eq
        expect(display_contents).to be == "123."
      end
    end

    describe "subtraction" do
      example do
        press 4, 5, 6, :-, 1, 2, 3, :eq
        expect(display_contents).to be == "333."
      end

      example do
        press 4, 5, 6, :-, 1, 2, 3, :-
        expect(display_contents).to be == "333."

        press 3, 2, 1, :eq
        expect(display_contents).to be == "12."
      end
    end

    describe "multiplication" do
      example do
        press 5, :*, 6, :eq
        expect(display_contents).to be == "30."
      end
    end

    describe "division" do
      example do
        press 5, 6, :/, 8, :eq
        expect(display_contents).to be == "7."
      end
    end

    describe "negative numbers" do
      example do
        press 1, 2, 3, :plus_minus, :eq
        expect(display_contents).to be == "-123."
      end

      example do
        press 1, 2, 3, :+, 6, 7, :plus_minus, :eq
        expect(display_contents).to be == "56."
      end

      example do
        press 1, 2, 3, :+, 6, :plus_minus, 7, :eq
        expect(display_contents).to be == "56."
      end

      example do
        press 1, 2, 3, :+, :plus_minus, 7, :eq
        expect(display_contents).to be == "130."
      end
    end

    describe "decimal maths" do
      example "addition" do
        press 1, 2, :point, 3, 4, :+,
              5, 6, :point, 7, 8, :eq
        expect(display_contents).to be == "69.12"
      end

      example "subtraction" do
        press 5, 6, :point, 7, 8, :-,
              1, 2, :point, 3, 4, :eq
        expect(display_contents).to be == "44.44"
      end

      example "multiplication" do
        press 1, 2, :point, 3, 4, :*,
              5, 6, :point, 7, 8, :eq
        expect(display_contents).to be == "700.6652"
      end

      example "division" do
        press 5, 6, :point, 7, 8, :/,
              1, 2, :point, 3, 4, :eq
        expect(display_contents).to be == "4.601296596"
      end
    end

    describe "memory" do
      describe "adding" do
        example do
          press 1, 2, 3, :m_plus, :+,
                4, 5, 6, :ac,
                :mr
          expect(display_contents).to be == "123."
        end

        example do
          press 1, 2, 3, :m_plus,
                4, 5, 6, :m_plus,
                :mr
          expect(display_contents).to be == "579."
        end

        example do
          press 1, 2, :m_plus, :ac,
                3, 4, :m_plus, :ac,
                4, 5, :m_plus, :ac,
                :mr
          expect(display_contents).to be == "91."
        end
      end

      describe "subtracting" do
        example do
          press 1, 2, 3, :m_minus, :+,
                4, 5, 6, :ac,
                :mr
          expect(display_contents).to be == "-123."
        end

        example do
          press 1, 2, 3, :m_minus,
                4, 5, 6, :m_minus,
                :mr
          expect(display_contents).to be == "-579."
        end

        example do
          press 1, 2, :m_minus, :ac,
                3, 4, :m_minus, :ac,
                4, 5, :m_minus, :ac,
                :mr
          expect(display_contents).to be == "-91."
        end

        describe "storing mid-calculation" do
          example do
            press 1, 2, 3, :m_plus, :ac,
                  4, 5, 6, :+,
                  7, 8, 9, :m_plus
            expect(display_contents).to be == "1245."

            press :mr
            expect(display_contents).to be == "1368."
          end

          example do
            press 7, 8, 9, :m_plus, :ac,
                  4, 5, 6, :+,
                  1, 2, 3, :m_minus
            expect(display_contents).to be == "579."

            press :mr
            expect(display_contents).to be == "210."
          end
        end
      end

      describe "re-using a number in the display" do
        example do
          press 3, 9,
                :m_plus, :m_plus, :m_plus,
                :m_minus,
                :mr
          expect(display_contents).to be == "78."
        end
      end

      describe "clearing" do
        example do
          press 8, 1, :m_plus,
                2, 5, :m_minus,
                :mr,
                :mc
          expect(display_contents).to be == "56."

          press :mr
          expect(display_contents).to be == "0."
        end
      end
    end
  end
end