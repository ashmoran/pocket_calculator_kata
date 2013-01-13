require 'bigdecimal'
require 'state_machine'

class DigitBuffer
  state_machine initial: :integer do

  end

  def initialize(options)
    @size = options.fetch(:size)
    clear

    super()
  end

  def clear
    @digits = [ ]
  end

  def add_digit(digit)
    @digits << digit unless full?
  end

  def point
    add_digit(".") unless point_set?
  end

  def delete_digit
    deleted_digit = @digits.pop
    @digits.pop if deleted_digit == "."
    @digits.pop if @digits.last == "."
  end

  def toggle_sign
    if @digits.first == "-"
      @digits.shift
    else
      @digits.unshift("-")
    end
  end

  def read_in_number(number)
    number = BigDecimal(number)
    @digits =
      if number.frac.zero?
        number.to_i
      else
        number.to_f
      end.to_s.chars.to_a
  end

  def to_number
    BigDecimal(@digits.join)
  end

  def to_s
    if to_number.frac.zero?
      "#{to_number.to_i}."
    else
      to_number.to_f.to_s
    end
  end

  private

  def full?
    @digits.select { |digit| digit =~ /^[0-9]$/ }.length >= @size
  end

  def point_set?
    @digits.include?(".")
  end
end