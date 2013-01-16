require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  state_machine initial: :clean do
    event :clear do
      transition any => :clean
    end

    event :point do
      transition [ :clean, :integer ]   => :point_pending
    end

    event :decimal_entered do
      transition any => :decimal
    end

    event :integer_entered do
      transition any => :integer
    end

    state :clean do
      def __add_digit(digit)
        @digits << digit
        integer_entered
      end

      def point
        @digits << "0"
        super
      end

      def _delete_digit(deleted_digit)
        integer_entered
      end

      def to_s
        "0."
      end
    end

    state :integer do
      def __add_digit(digit)
        return if trying_to_add_leading_zero?(digit)
        @digits << digit
      end

      def _delete_digit(deleted_digit)

      end

      def to_s
        # We have a fake "zero" state, like clean but it can have a sign
        if buffer_empty?
          @sign + "0."
        else
          @sign + @digits.join + "."
        end
      end

      private

      def trying_to_add_leading_zero?(digit)
        digit == "0" && @digits == %w[ 0 ]
      end
    end

    state :point_pending do
      def __add_digit(digit)
        @digits << "."
        @digits << digit
        decimal_entered
      end

      def _delete_digit(deleted_digit)
        integer_entered
      end

      def to_s
        @sign + @digits.join + "."
      end
    end

    state :decimal do
      def __add_digit(digit)
        @digits << digit
      end

      def _delete_digit(deleted_digit)
        if deleted_digit == "."
          delete_digit
          integer_entered
        end
      end

      def to_s
        @sign + @digits.join
      end
    end
  end

  state_machine :capacity, initial: :not_full do
    event :filled_up do
      transition :not_full => :full
    end

    event :buffer_capacity_freed do
      transition :full => :not_full
    end

    state :not_full do
      def _add_digit(digit)
        __add_digit(digit)
      end
    end

    state :full do
      def _add_digit(digit)
        # NOOP
      end
    end
  end

  def initialize(options)
    super()

    @size = options.fetch(:size)
    clear
  end

  def clear
    @sign = ""
    @digits = [ ]
    super
  end

  def add_digit(digit)
    _add_digit(digit)
    check_buffer_capacity
  end

  def delete_digit
    _delete_digit(@digits.pop)
    @sign = "" if buffer_empty?
    check_buffer_capacity
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

  def ensure_not_empty
    if buffer_empty?
      @digits << "0"
      @sign = ""
    end
  end

  def check_buffer_capacity
    if buffer_full?
      filled_up
    else
      buffer_capacity_freed
    end
  end

  def buffer_empty?
    digits_in_buffer.empty?
  end

  def buffer_full?
    digits_in_buffer.length >= @size
  end

  def digits_in_buffer
    @digits.select { |digit| digit =~ /^[0-9]$/ }
  end

  def read_in_integer_digits(digit_string)
    digit_string.chars.each do |digit|
      add_digit(digit)
    end
  end
end