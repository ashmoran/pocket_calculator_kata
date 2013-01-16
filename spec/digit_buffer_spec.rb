require 'spec_helper'

require 'digit_buffer'

describe DigitBuffer do
  subject(:buffer) { DigitBuffer.new(size: 5) }

  context "new" do
    its(:to_number) { should be == 0 }
    its(:to_s) { should be == "0." }

    it "can't have leading zeros" do
      buffer.add_digit("0")
      buffer.add_digit("0")
      buffer.add_digit("0")

      expect(buffer.to_number).to be == 0
      expect(buffer.to_s).to be == "0."
    end
  end

  context "with digits" do
    before(:each) do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.add_digit("3")
    end

    its(:to_number) { should be == 123 }
    its(:to_s) { should be == "123." }

    context "filled to the limit" do
      before(:each) do
        buffer.add_digit("4")
        buffer.add_digit("5")
      end

      its(:to_number) { should be == 12345 }

      it "cannot have further digits added" do
        expect {
          buffer.add_digit("6")
        }.to_not change { buffer.to_number }
      end
    end

    context "filled to the limit with a decimal point" do
      before(:each) do
        buffer.point
        buffer.add_digit("4")
        buffer.add_digit("5")
      end

      its(:to_number) { should be == BigDecimal("123.45") }

      it "cannot have further digits added" do
        expect {
          buffer.add_digit("6")
        }.to_not change { buffer.to_number }
      end
    end
  end

  describe "#toggle_sign" do
    context "new buffer" do
      it "can't be negated" do
        buffer.toggle_sign
        expect(buffer.to_number).to be == 0
        expect(buffer.to_s).to be == "0."
      end
    end

    describe "negating zero" do
      context "with an explicit zero" do
        before(:each) do
          buffer.add_digit("0")
        end

        it "can be negated" do
          buffer.toggle_sign

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "-0."
        end
      end

      context "after entering a decimal point" do
        before(:each) do
          buffer.point
        end

        it "can be negated" do
          buffer.toggle_sign

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "-0."
        end
      end

      context "decimal zero" do
        before(:each) do
          buffer.point
          buffer.add_digit("0")
        end

        it "can be negated" do
          buffer.toggle_sign

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "-0.0"
        end
      end
    end

    describe "with digits" do
      before(:each) do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.add_digit("3")
      end

      specify {
        buffer.toggle_sign
        expect(buffer.to_number).to be == -123
        expect(buffer.to_s).to be == "-123."
      }

      specify {
        buffer.toggle_sign
        buffer.toggle_sign
        expect(buffer.to_number).to be == 123
        expect(buffer.to_s).to be == "123."
      }

      context "after clearing" do
        it "reverts to new-buffer behaviour" do
          buffer.clear
          buffer.toggle_sign
          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "0."
        end
      end
    end
  end

  describe "#delete_digit" do
    example do
      buffer.delete_digit
      expect(buffer.to_s).to be == "0."
    end

    example do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.add_digit("3")

      buffer.delete_digit
      expect(buffer.to_number).to be == 12
      expect(buffer.to_s).to be == "12."

      buffer.delete_digit
      buffer.delete_digit
      expect(buffer.to_number).to be == 0
      expect(buffer.to_s).to be == "0."

      buffer.delete_digit
      expect(buffer.to_s).to be == "0."
    end
  end

  describe "#read_in_number" do
    context "an integer" do
      before(:each) do
        buffer.read_in_number(123)
      end

      its(:to_number) { should be == 123 }
      its(:to_s) { should be == "123." }
    end

    context "an integer BigDecimal" do
      before(:each) do
        buffer.read_in_number(BigDecimal("123"))
      end

      its(:to_number) { should be == BigDecimal("123") }
      its(:to_s) { should be == "123." }
    end

    context "a fractional BigDecimal" do
      before(:each) do
        buffer.read_in_number(BigDecimal("12.3"))
      end

      its(:to_number) { should be == BigDecimal("12.3") }
      its(:to_s) { should be == "12.3" }
    end

    context "a negative BigDecimal" do
      before(:each) do
        buffer.read_in_number(BigDecimal("-12.3"))
      end

      its(:to_number) { should be == BigDecimal("-12.3") }
      its(:to_s) { should be == "-12.3" }

      it "can have its sign toggled" do
        buffer.toggle_sign

        expect(buffer.to_number).to be == BigDecimal("12.3")
        expect(buffer.to_s).to be == "12.3"
      end
    end
  end

  describe "decimals" do
    example do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.point

      expect(buffer.to_number).to be == 12
      expect(buffer.to_s).to be == "12."
    end

    example do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.point
      buffer.add_digit("3")

      expect(buffer.to_number).to be == BigDecimal("12.3")
      expect(buffer.to_s).to be == "12.3"
    end

    example do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.point
      buffer.add_digit("3")
      buffer.point
      buffer.add_digit("4")

      expect(buffer.to_number).to be == BigDecimal("12.34")
      expect(buffer.to_s).to be == "12.34"
    end

    example do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.point
      buffer.add_digit("0")
      buffer.add_digit("1")
      buffer.add_digit("0")

      expect(buffer.to_number).to be == BigDecimal("12.01")
      expect(buffer.to_s).to be == "12.010"
    end

    example "running out of space for decimal digits" do
      buffer.add_digit("1")
      buffer.add_digit("2")
      buffer.add_digit("3")
      buffer.add_digit("4")
      buffer.add_digit("5")
      buffer.point

      expect(buffer.to_number).to be == 12345
      expect(buffer.to_s).to be == "12345."
    end

    describe "deleting digits" do
      example do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.add_digit("3")
        buffer.point

        buffer.delete_digit

        expect(buffer.to_number).to be == 12
        expect(buffer.to_s).to be == "12."
      end

      example do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.point
        buffer.add_digit("3")

        buffer.delete_digit

        expect(buffer.to_number).to be == 12
        expect(buffer.to_s).to be == "12."
      end

      example do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.add_digit("3")
        buffer.point

        buffer.delete_digit
        buffer.add_digit("9")

        expect(buffer.to_number).to be == 129
        expect(buffer.to_s).to be == "129."
      end

      example do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.point
        buffer.add_digit("3")

        buffer.delete_digit

        expect(buffer.to_number).to be == 12
        expect(buffer.to_s).to be == "12."
      end

      example do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.point
        buffer.add_digit("3")

        buffer.delete_digit
        buffer.add_digit("4")

        expect(buffer.to_number).to be == BigDecimal("12.4")
        expect(buffer.to_s).to be == "12.4"
      end

      example do
        buffer.add_digit("1")
        buffer.add_digit("2")
        buffer.point
        buffer.add_digit("3")

        buffer.delete_digit
        buffer.delete_digit
        buffer.add_digit("4")

        expect(buffer.to_number).to be == 14
        expect(buffer.to_s).to be == "14."
      end

      example do
        buffer.add_digit("1")
        buffer.point
        buffer.add_digit("2")
        buffer.add_digit("3")

        buffer.delete_digit

        expect(buffer.to_number).to be == BigDecimal("1.2")
        expect(buffer.to_s).to be == "1.2"
      end

      example do
        buffer.add_digit("0")
        buffer.point
        buffer.add_digit("0")
        buffer.add_digit("0")
        buffer.add_digit("0")

        expect(buffer.to_number).to be == 0
        expect(buffer.to_s).to be == "0.000"
      end

      example do
        buffer.point
        buffer.add_digit("0")
        buffer.add_digit("0")
        buffer.add_digit("0")

        expect(buffer.to_number).to be == 0
        expect(buffer.to_s).to be == "0.000"
      end

      example do
        buffer.delete_digit
        buffer.toggle_sign

        expect(buffer.to_number).to be == 0
        expect(buffer.to_s).to be == "-0."
      end

      describe "deleting all of a negative number" do
        example do
          buffer.add_digit("0")
          buffer.toggle_sign
          buffer.delete_digit

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "0."
        end

        example do
          buffer.point
          buffer.toggle_sign
          buffer.delete_digit

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "0."
        end

        example do
          buffer.point
          buffer.toggle_sign
          buffer.delete_digit

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "0."
        end

        example do
          buffer.point
          buffer.add_digit("0")
          buffer.toggle_sign
          buffer.delete_digit
          buffer.delete_digit

          expect(buffer.to_number).to be == 0
          expect(buffer.to_s).to be == "0."
        end
      end
    end

    describe "#read_in_number" do
      describe "followed by deleting digits" do
        example do
          buffer.read_in_number(BigDecimal("123"))

          buffer.delete_digit

          expect(buffer.to_number).to be == 12
          expect(buffer.to_s).to be == "12."
        end

        example do
          buffer.read_in_number(BigDecimal("12.3"))

          buffer.delete_digit

          expect(buffer.to_number).to be == 12
          expect(buffer.to_s).to be == "12."
        end

        example do
          buffer.read_in_number(BigDecimal("12.3"))

          buffer.delete_digit
          buffer.delete_digit

          expect(buffer.to_number).to be == 1
          expect(buffer.to_s).to be == "1."
        end

        example do
          buffer.read_in_number(BigDecimal("1.23"))

          buffer.delete_digit

          expect(buffer.to_number).to be == BigDecimal("1.2")
          expect(buffer.to_s).to be == "1.2"
        end
      end

      describe "followed by adding and deleting digits" do
        example do
          buffer.read_in_number(BigDecimal("123"))

          buffer.add_digit("4")
          buffer.delete_digit

          expect(buffer.to_number).to be == 123
          expect(buffer.to_s).to be == "123."
        end

        example do
          buffer.read_in_number(BigDecimal("123"))

          buffer.point
          buffer.delete_digit

          expect(buffer.to_number).to be == 12
          expect(buffer.to_s).to be == "12."
        end

        example do
          buffer.read_in_number(BigDecimal("12.3"))

          buffer.add_digit("4")
          buffer.delete_digit

          expect(buffer.to_number).to be == BigDecimal("12.3")
          expect(buffer.to_s).to be == "12.3"
        end
      end

      example "handling a number longer than the buffer size" do
        buffer.read_in_number(BigDecimal("123.123"))

        expect(buffer.to_number).to be == BigDecimal("123.12")
        expect(buffer.to_s).to be == "123.12"
      end
    end
  end
end