require 'bigdecimal'
require 'state_machine'

class DigitBufferPositional
  state_machine initial: :clean do
    event :clear do
      transition any => :clean
    end

    event :point do
      transition [ :clean, :empty_but_dirty, :integer ]   => :point_pending
    end

    event :decimal_entered do
      transition any => :decimal
    end

    event :point_pending_entered do
      transition any => :point_pending
    end

    event :integer_entered do
      transition any => :integer
    end

    event :empty_but_dirty_entered do
      transition any => :empty_but_dirty
    end

    state :clean do
      def _add_digit(digit)
        @digits << digit
        integer_entered
      end

      def point
        @digits << "0"
        super
      end

      def _delete_digit(deleted_digit)
        empty_but_dirty_entered
      end

      def to_s
        "0."
      end
    end

    state :empty_but_dirty do
      def _add_digit(digit)
        @digits << digit
        integer_entered
      end

      def _delete_digit(deleted_digit)

      end

      def point
        @digits << "0"
        super
      end

      def to_s
        @sign + "0."
      end
    end

    state :integer do
      def _add_digit(digit)
        return if trying_to_add_leading_zero?(digit)
        @digits << digit
      end

      def _delete_digit(deleted_digit)

      end

      def to_s
        _to_s
      end

      private

      def trying_to_add_leading_zero?(digit)
        digit == "0" && @digits == %w[ 0 ]
      end
    end

    state :point_pending do
      def _add_digit(digit)
        @digits << digit
        @exponent += 1
        decimal_entered
      end

      def _delete_digit(deleted_digit)
        integer_entered
      end

      def to_s
        _to_s
      end
    end

    state :decimal do
      def _add_digit(digit)
        @digits << digit
        @exponent += 1
      end

      def _delete_digit(deleted_digit)
        @exponent -= 1
        point_pending_entered if @exponent == 1
      end

      def to_s
        _to_s
      end
    end
  end

  def initialize(options)
    super()

    @size = options.fetch(:size)
    clear
  end

  def clear
    @sign     = ""
    @exponent = 1
    @digits   = [ ]
    super
  end

  def add_digit(digit)
    _add_digit(digit) unless buffer_full?
  end

  def delete_digit
    _delete_digit(@digits.pop)
    if buffer_empty?
      @sign = ""
      empty_but_dirty_entered
    end
  end

  def toggle_sign
    if @sign == ""
      @sign = "-"
    else
      @sign = ""
    end
  end

  def read_in_number(number)
    clear

    number = BigDecimal(number)
    integer_digits, decimal_digits = number.abs.to_s("F").split(".")

    read_in_integer_digits(integer_digits)
    if number.frac.nonzero?
      point
      read_in_integer_digits(decimal_digits)
    end

    toggle_sign if number < 0
  end

  def to_number
    BigDecimal(to_s)
  end

  private

  def _to_s
    digits = @digits.dup
    digits.insert(-@exponent, ".")
    @sign + digits.join
  end

  def buffer_empty?
    @digits.empty?
  end

  def buffer_full?
    @digits.length >= @size
  end

  def read_in_integer_digits(digit_string)
    digit_string.chars.each do |digit|
      add_digit(digit)
    end
  end
end