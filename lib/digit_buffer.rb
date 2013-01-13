class DigitBuffer
  def initialize(options)
    @size = options.fetch(:size)
    clear
  end

  def clear
    @digits = [ ]
  end

  def add_digit(digit)
    @digits << digit if @digits.length < @size
  end

  def delete_digit
    @digits.pop
  end

  def toggle_sign
    if @digits.first == "-"
      @digits.shift
    else
      @digits.unshift("-")
    end
  end

  def read_in_number(number)
    @digits = number.to_s.chars.to_a
  end

  def to_number
    @digits.join.to_i
  end

  def to_s
    "#{to_number}."
  end
end