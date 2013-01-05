require 'calculator'

describe Calculator do
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
      calculator.n1
      expect(display_contents).to be == "1"
    end
  end
end