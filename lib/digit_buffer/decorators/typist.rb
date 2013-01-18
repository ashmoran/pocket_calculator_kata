require 'forwardable'
require 'bigdecimal'

class DigitBuffer
  module Decorators
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

        toggle_sign if number < 0
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