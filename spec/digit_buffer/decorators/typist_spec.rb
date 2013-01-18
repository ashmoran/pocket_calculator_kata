require 'spec_helper'

require 'digit_buffer'

class DigitBuffer
  module Decorators
    describe Typist do
      let(:buffer) { mock(DigitBuffer) }

      subject(:typist) { Typist.new(buffer) }

      describe "#read_in_number" do
        context "a BigDecimal" do
          context "integer" do
            let(:number) { BigDecimal("123") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered
              buffer.should_not_receive(:point)

              typist.read_in_number(number)
            end
          end

          context "decimal" do
            let(:number) { BigDecimal("1.23") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:point).ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered

              typist.read_in_number(number)
            end
          end

          context "decimal < 0" do
            let(:number) { BigDecimal("0.0123") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("0").ordered
              buffer.should_receive(:point).ordered
              buffer.should_receive(:add_digit).with("0").ordered
              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered

              typist.read_in_number(number)
            end
          end

          context "0" do
            let(:number) { BigDecimal("0") }

            it "currently reads in the zero (I'm not sure if this is correct)" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("0").ordered
              buffer.should_not_receive(:point)

              typist.read_in_number(number)
            end
          end
        end

        context "a String" do
          let(:number) { "000.012300" }

          it "reads in the digits as if it was a BigDecimal" do
            buffer.should_receive(:clear).ordered

            buffer.should_receive(:add_digit).with("0").ordered
            buffer.should_receive(:point).ordered
            buffer.should_receive(:add_digit).with("0").ordered
            buffer.should_receive(:add_digit).with("1").ordered
            buffer.should_receive(:add_digit).with("2").ordered
            buffer.should_receive(:add_digit).with("3").ordered

            typist.read_in_number(number)
          end
        end
      end
    end
  end
end