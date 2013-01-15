require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  state_machine initial: :integer do
    event :clear do
      transition any => :integer
    end

    event :point do
      transition :integer => :point_pending
    end

    event :decimal_entered do
      transition any => :decimal
    end

    event :integer_entered do
      transition any => :integer
    end

    state :integer do
      def add_digit(digit)
        return if digit == "0" && @digits.join =~ /^-?0$/
        @digits << digit unless full?
      end

      def point
        @digits << "0" if @digits.join.empty?
        super
      end

      def delete_digit
        @digits.pop
      end

      def to_s
        if to_number != 0
          "#{to_number.to_i}."
        else
          if @digits.none? { |digit| digit =~ /^[0-9]$/ }
            "0" + @digits.join + "."
          else
            @digits.join + "."
          end
        end
      end
    end

    state :point_pending do
      def add_digit(digit)
        unless full?
          @digits << "."
          @digits << digit
        end

        decimal_entered
      end

      def delete_digit
        @digits.pop
      end

      def to_s
        if to_number != 0
          "#{to_number.to_i}."
        else
          if @digits.none? { |digit| digit =~ /^[0-9]$/ }
            "0" + @digits.join + "."
          else
            @digits.join + "."
          end
        end
      end
    end

    state :decimal do
      def add_digit(digit)
        @digits << digit unless full?
      end

      def delete_digit
        deleted_digit = @digits.pop
        if deleted_digit == "."
          @digits.pop
          integer_entered
        end
      end

      def to_s
        @digits.join
      end
    end
  end

  def initialize(options)
    super()

    @size = options.fetch(:size)
    clear
  end

  def clear
    @digits = [ ]
    super
  end

  def toggle_sign
    return if @digits.none? { |digit| digit =~ /^[0-9]$/ }

    if @digits.first == "-"
      @digits.shift
    else
      @digits.unshift("-")
    end
  end

  def read_in_number(number)
    clear
    number = BigDecimal(number)
    read_in_integer_digits(number.fix.to_i.to_s)
    if number.frac.nonzero?
      point
      read_in_integer_digits(number.frac.to_s("F")[2..-1])
    end
  end

  def to_number
    BigDecimal(@digits.join)
  end

  private

  def full?
    @digits.select { |digit| digit =~ /^[0-9]$/ }.length >= @size
  end

  def point_set?
    @digits.include?(".")
  end

  def read_in_integer_digits(digit_string)
    digit_string.chars.each do |digit|
      add_digit(digit)
    end
  end
end