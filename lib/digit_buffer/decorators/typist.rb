require 'delegate'
require 'bigdecimal'

class DigitBuffer
  module Decorators
    class Typist < SimpleDelegator
      def read_in_number(number)
        clear

        number = BigDecimal.new(number)
        integer_digits, decimal_digits = split_number(number)

        read_in_integer_digits(integer_digits)
        if number.frac.nonzero?
          point
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
          add_digit(digit)
        end
      end
    end
  end
end