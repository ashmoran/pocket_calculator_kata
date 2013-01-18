require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  PROTOCOL = [
    :clear, :add_digit, :delete_digit, :point, :toggle_sign, :to_number, :to_s , :read_in_number
  ]
end

require_relative 'digit_buffer/decorators'

class DigitBuffer
  class << self
    def new(*args)
      buffer = allocate
      buffer.send(:initialize, *args)

      # The order of this nesting matters, and it's interesting why
      Decorators::Typist.new(
        Decorators::ScreenProtector.new(
          buffer
        )
      )
    end
  end

  state_machine initial: :integer do
    event :clear do
      transition any => :integer
    end

    event :point do
      transition :integer => :point_pending
    end

    event :decimal_entered do
      transition :point_pending => :decimal
    end

    event :point_pending_entered do
      transition [ :integer, :decimal ] => :point_pending
    end

    event :integer_entered do
      transition :point_pending => :integer
    end

    state :integer do
      def _add_digit(digit)
        @digits.shift if @digits == %w[ 0 ]
        @digits << digit
      end

      def _delete_digit(deleted_digit)
        # NOOP
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
    ensure_buffer_contains_at_least_zero
    super
  end

  def add_digit(digit)
    _add_digit(digit) unless full?
  end

  def delete_digit
    _delete_digit(@digits.pop)
    @sign = "" if empty?
    ensure_buffer_contains_at_least_zero
  end

  def point
    ensure_buffer_contains_at_least_zero
    super
  end

  def to_number
    BigDecimal(to_s)
  end

  private

  def ensure_buffer_contains_at_least_zero
    @digits << "0" if empty?
  end

  def toggle_sign
    if @sign == ""
      @sign = "-"
    else
      @sign = ""
    end
  end

  def to_s
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