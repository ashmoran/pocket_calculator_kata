require 'forwardable'
require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  module Decorators
    # The calculator has the questionable feature that if you press +-
    # as the first key, it doesn't toggle the sign. If you do anything
    # that makes the display "dirty" you then can toggle the sign.
    #
    # Arguably this behaviour is a bug, but my first attempt at
    # implementing it massively complicated the DigitBuffer. Extracting
    # it to a decorator at least allows us to isolate the weirdness.

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