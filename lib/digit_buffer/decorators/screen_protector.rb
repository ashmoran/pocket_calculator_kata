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
    # It also means if Casio ever fix this "bug", we can fix it here
    # by simply removing the ScreenProtector object from the decorator
    # chain.

    class ScreenProtector
      extend Forwardable
      def_delegators :@buffer, *DigitBuffer::PROTOCOL

      def initialize(buffer)
        @buffer = buffer
        @clean = true
        super()
      end

      def toggle_sign
        @buffer.toggle_sign if !@clean
      end

      def add_digit(digit)
        @buffer.add_digit(digit)
        @clean = false
      end

      def delete_digit
        @buffer.delete_digit
        @clean = false
      end

      def point
        @buffer.point
        @clean = false
      end

      def clear
        @buffer.clear
        @clean = true
      end
    end
  end
end