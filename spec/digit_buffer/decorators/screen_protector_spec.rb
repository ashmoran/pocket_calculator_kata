require 'spec_helper'

require 'digit_buffer'

class DigitBuffer
  module Decorators
    describe ScreenProtector do
      let(:stub_digit_buffer_protocol) {
        DigitBuffer::PROTOCOL.inject({ }) { |stubs, message|
          stubs[message] = nil
          stubs
        }
      }

      let(:buffer) { mock(DigitBuffer, stub_digit_buffer_protocol) }

      subject(:screen_protector) { ScreenProtector.new(buffer) }

      context "new" do
        it "drops :toggle_sign messages" do
          buffer.should_not_receive(:toggle_sign)
          screen_protector.toggle_sign
        end
      end

      context "after adding a digit" do
        before(:each) do
          screen_protector.add_digit("1")
        end

        it "delegates :toggle_sign messages" do
          buffer.should_receive(:toggle_sign)
          screen_protector.toggle_sign
        end

        context "and then clearing" do
          before(:each) do
            screen_protector.clear
          end

          it "drops :toggle_sign messages" do
            buffer.should_not_receive(:toggle_sign)
            screen_protector.toggle_sign
          end
        end
      end

      context "after deleting a digit" do
        before(:each) do
          screen_protector.delete_digit
        end

        it "delegates :toggle_sign messages" do
          buffer.should_receive(:toggle_sign)
          screen_protector.toggle_sign
        end

        context "and then clearing" do
          before(:each) do
            screen_protector.clear
          end

          it "drops :toggle_sign messages" do
            buffer.should_not_receive(:toggle_sign)
            screen_protector.toggle_sign
          end
        end
      end

      context "after setting the decimal point" do
        before(:each) do
          screen_protector.point
        end

        it "delegates :toggle_sign messages" do
          buffer.should_receive(:toggle_sign)
          screen_protector.toggle_sign
        end

        context "and then clearing" do
          before(:each) do
            screen_protector.clear
          end

          it "drops :toggle_sign messages" do
            buffer.should_not_receive(:toggle_sign)
            screen_protector.toggle_sign
          end
        end
      end
    end
  end
end