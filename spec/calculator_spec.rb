require 'spec_helper'

require 'calculator'

describe Calculator do
  include PocketCalculatorHelper

  subject(:calculator) { Calculator.new(display: self) }

  def update(contents)
    @displayed_values << contents
  end

  def display_contents
    @displayed_values.last
  end

  before(:each) do
    @displayed_values = [ ]
  end

  describe "AC" do
    specify {
      expect { calculator.ac }.to change { display_contents }.from(nil).to("0")
    }
  end

  describe "typing" do
    before(:each) do
      calculator.ac
    end

    example do
      press_digit 1
      expect(display_contents).to be == "1"
    end

    example do
      press_digits 1, 2
      expect(display_contents).to be == "12"
    end

    example do
      press_digits 1, 2, 3, 4, 5, 6, 7, 8, 9, 0

      expect(display_contents).to be == "1234567890"
    end

    example do
      press_digits 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1

      expect(display_contents.length).to be == 10
      expect(display_contents).to be == "1234567890"
    end

    describe "addition" do
      example do
        press_digits 1, 2, 3
        calculator.plus
        expect(display_contents).to be == "123"

        press_digit 4
        expect(display_contents).to be == "4"
        press_digits 5, 6
        expect(display_contents).to be == "456"
      end
    end
  end

  describe "addition", focus: true do
    before(:each) do
      calculator.ac
    end

    example do
      press_digits 1, 2, 3
      calculator.plus
      press_digits 4, 5, 6
      calculator.equals

      expect(display_contents).to be == "579"
    end

    it "works when waiting for a new number" do
      pending
    end

    it "works when building a number" do
      pending
    end
  end
end