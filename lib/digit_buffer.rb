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
      def __add_digit(digit)
        return if digit == "0" && explicit_integer_zero?
        @digits << digit
      end

      def point
        @digits << "0" if buffer_empty?
        super
      end

      def _delete_digit(deleted_digit)

      end

      def to_s
        if to_number.zero?
          if buffer_empty?
            "0" + @digits.join + "."
          else
            (@sign + @digits.join + ".").lstrip
          end
        else
          "#{to_number.to_i}."
        end
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
        if to_number.zero?
          (@sign + @digits.join + ".").lstrip
        else
          "#{to_number.to_i}."
        end
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
        @digits.join
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
    @sign = " "
    @digits = [ ]
    super
  end

  def add_digit(digit)
    _add_digit(digit)
    check_buffer_state
  end

  def delete_digit
    _delete_digit(@digits.pop)
    check_buffer_state
  end

  def toggle_sign
    if @sign == " "
      @sign = "-"
    else
      @sign = " "
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
    BigDecimal(@sign + @digits.join)
  end

  private

  def check_buffer_state
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

  def explicit_integer_zero?
    @digits == %w[ 0 ]
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