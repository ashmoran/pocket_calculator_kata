require 'spec_helper'

require 'digit_buffer'

class DigitBuffer
  module Decorators
    describe Typist do
      let(:buffer) { mock(DigitBuffer) }

      subject(:typist) { Typist.new(buffer) }

      describe "#read_in_number" do
        context "a BigDecimal" do
          context "positive integer" do
            let(:number) { BigDecimal("123") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered
              buffer.should_not_receive(:point)
              buffer.should_not_receive(:toggle_sign)

              typist.read_in_number(number)
            end
          end

          context "positive decimal" do
            let(:number) { BigDecimal("1.23") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:point).ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered
              buffer.should_not_receive(:toggle_sign)

              typist.read_in_number(number)
            end
          end

          context "negative integer" do
            let(:number) { BigDecimal("-123") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered
              buffer.should_receive(:toggle_sign).ordered
              buffer.should_not_receive(:point)

              typist.read_in_number(number)
            end
          end

          context "negative decimal" do
            let(:number) { BigDecimal("-1.23") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:point).ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered
              buffer.should_receive(:toggle_sign).ordered

              typist.read_in_number(number)
            end
          end

          context "0 < decimal < 1" do
            let(:number) { BigDecimal("0.0123") }

            it "reads in the digits" do
              buffer.should_receive(:clear).ordered

              buffer.should_receive(:add_digit).with("0").ordered
              buffer.should_receive(:point).ordered
              buffer.should_receive(:add_digit).with("0").ordered
              buffer.should_receive(:add_digit).with("1").ordered
              buffer.should_receive(:add_digit).with("2").ordered
              buffer.should_receive(:add_digit).with("3").ordered
              buffer.should_not_receive(:toggle_sign)

              typist.read_in_number(number)
            end
          end

          context "0" do
            context "as a BigDecimal" do
              let(:number) { BigDecimal("0") }

              it "currently reads in the zero" do
                buffer.should_receive(:clear)

                buffer.should_not_receive(:add_digit)
                buffer.should_not_receive(:point)
                buffer.should_not_receive(:toggle_sign)

                typist.read_in_number(number)
              end
            end

            context "as a String" do
              let(:number) { "0" }

              it "currently reads in the zero" do
                buffer.should_receive(:clear)

                buffer.should_not_receive(:add_digit)
                buffer.should_not_receive(:point)
                buffer.should_not_receive(:toggle_sign)

                typist.read_in_number(number)
              end
            end
          end
        end

        context "a String" do
          let(:number) { "-000.012300" }

          it "reads in the digits as if it was a BigDecimal" do
            buffer.should_receive(:clear).ordered

            buffer.should_receive(:add_digit).with("0").ordered
            buffer.should_receive(:point).ordered
            buffer.should_receive(:add_digit).with("0").ordered
            buffer.should_receive(:add_digit).with("1").ordered
            buffer.should_receive(:add_digit).with("2").ordered
            buffer.should_receive(:add_digit).with("3").ordered
            buffer.should_receive(:toggle_sign).ordered

            typist.read_in_number(number)
          end
        end

        context "a Float" do
          let(:number) { -0.25 }

          it "reads in the digits as if it was a BigDecimal" do
            buffer.should_receive(:clear).ordered

            buffer.should_receive(:add_digit).with("0").ordered
            buffer.should_receive(:point).ordered
            buffer.should_receive(:add_digit).with("2").ordered
            buffer.should_receive(:add_digit).with("5").ordered
            buffer.should_receive(:toggle_sign).ordered

            typist.read_in_number(number)
          end
        end
      end
    end
  end
end