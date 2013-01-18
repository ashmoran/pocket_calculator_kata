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
            became_dirty
            @buffer.add_digit(digit)
          end

          def delete_digit
            became_dirty
            @buffer.delete_digit
          end

          def point
            became_dirty
            @buffer.point
          end
        end

        state :dirty do
          extend Forwardable
          def_delegators :@buffer, *DigitBuffer::PROTOCOL

          def clear
            became_clean
            @buffer.clear
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