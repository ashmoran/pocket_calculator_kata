require 'forwardable'
require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  module Decorators
    class ScreenProtector
      state_machine initial: :clean do
        event :became_dirty do
          transition :clean => :dirty
        end

        event :became_clean do
          transition :dirty => :clean
        end

        state :clean do
          extend Forwardable
          def_delegators :@buffer, *DigitBuffer::PROTOCOL

          def toggle_sign
            # NOOP
          end

          def add_digit(digit)
            @buffer.add_digit(digit)
            became_dirty
          end

          def delete_digit
            @buffer.delete_digit
            became_dirty
          end

          def point
            @buffer.point
            became_dirty
          end
        end

        state :dirty do
          extend Forwardable
          def_delegators :@buffer, *DigitBuffer::PROTOCOL

          def clear
            @buffer.clear
            became_clean
          end
        end
      end

      def initialize(buffer)
        @buffer = buffer
        super()
      end
    end
  end
end