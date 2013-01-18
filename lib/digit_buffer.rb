require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  PROTOCOL = [ :clear, :add_digit, :delete_digit, :point, :toggle_sign, :to_number, :to_s ]
end

require_relative 'digit_buffer/decorators'

class DigitBuffer
  class << self
    def new(*args)
      buffer = allocate
      buffer.send(:initialize, *args)
      Decorators::Typist.new(buffer)
    end
  end

  state_machine initial: :clean do
    event :clear do
      transition any => :clean
    end

    event :point do
      transition [ :clean, :integer ]   => :point_pending
    end

    event :decimal_entered do
      transition :point_pending => :decimal
    end

    event :point_pending_entered do
      transition [ :integer, :decimal ] => :point_pending
    end

    event :integer_entered do
      transition [ :clean, :point_pending ] => :integer
    end

    state :clean do
      def _add_digit(digit)
        @digits << digit
        integer_entered
      end

      def _delete_digit(deleted_digit)
        integer_entered
      end

      def toggle_sign
        # NOOP
      end

      def to_s
        # Nope, we need to make sure the sign can't change...
        # _to_s
        "0."
      end
    end

    state :integer do
      def _add_digit(digit)
        return if trying_to_add_leading_zero?(digit)
        @digits.shift if @digits == %w[ 0 ]
        @digits << digit
      end

      def _delete_digit(deleted_digit)
        # NOOP
      end

      def toggle_sign
        _toggle_sign
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

      def toggle_sign
        _toggle_sign
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

      def toggle_sign
        _toggle_sign
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
    _add_digit(digit) unless full?
  end

  def delete_digit
    _delete_digit(@digits.pop)
    if empty?
      @sign = ""
    end
    ensure_not_empty
  end

  def point
    ensure_not_empty
    super
  end

  def to_number
    BigDecimal(to_s)
  end

  private

  def ensure_not_empty
    @digits << "0" if empty?
  end

  def _toggle_sign
    if @sign == ""
      @sign = "-"
    else
      @sign = ""
    end
  end

  def _to_s
    digits = @digits.dup
    digits.insert(-@exponent, ".")
    @sign + digits.join
  end

  def empty?
    @digits.empty?
  end

  def full?
    @digits.length >= @size
  end
end