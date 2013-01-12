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

  describe "typing numbers" do
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
  end
end