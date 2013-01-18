require 'forwardable'
require 'bigdecimal'

class DigitBuffer
  module Decorators
    # Typist decorates a DigitBuffer with the ability to type in
    # a number from a numeric value. This is useful because it
    # guarantees we're putting the buffer in the correct state
    # (integer or decimal). It lets us do it by sending simple
    # instructions to the buffer rather than doing state
    # inference afterwards, which means this can be implemented
    # outside the buffer itself.

    class Typist
      extend Forwardable
      def_delegators :@buffer, *DigitBuffer::PROTOCOL

      def initialize(buffer)
        @buffer = buffer
      end

      def read_in_number(number)
        @buffer.clear

        number = BigDecimal.new(number)
        integer_digits, decimal_digits = split_number(number)

        read_in_integer_digits(integer_digits)
        if number.frac.nonzero?
          @buffer.point
          read_in_integer_digits(decimal_digits)
        end

        @buffer.toggle_sign if number < 0
      end

      private

      def split_number(number)
        number.abs.to_s("F").split(".")
      end

      def read_in_integer_digits(digit_string)
        digit_string.chars.each do |digit|
          @buffer.add_digit(digit)
        end
      end
    end
  end
end