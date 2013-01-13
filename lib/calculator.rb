require 'state_machine'
require 'facets/enumerable'

class Calculator
  class DigitBuffer
    def clear
      @digits = [ ]
    end

    def add_digit(digit)
      @digits << digit if @digits.length < 10
    end

    def delete_digit
      @digits.pop
      # add_digit("0") if @digits.empty?
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
      to_number.to_s
    end

    def join
      @digits.join
    end
  end

  def initialize(dependencies)
    @display = dependencies.fetch(:display)

    @digits                   = DigitBuffer.new
    @intermediate_calculation = nil
    @next_operation           = :do_nothing
    @memory                   = 0

    super()
  end

  state_machine initial: :off do
    event :turn_on do
      transition :off => :building_number
    end

    event :start_building_number do
      transition :waiting_for_new_number => :building_number
    end

    event :number_completed do
      transition :building_number => :waiting_for_new_number
    end

    before_transition :building_number => :waiting_for_new_number, do: :store_number

    state :off do
      def ac
        turn_on
        clear_everything
      end

      def digit_pressed(digit)
        # NOOP
      end

      def backspace
        # NOOP
      end
    end

    state :waiting_for_new_number do
      def ac
        clear_everything
      end

      def digit_pressed(digit)
        clear_buffer
        @digits.add_digit(digit)
        update_display
        start_building_number
      end

      def handle_operation(next_operation)
        @next_operation = next_operation
      end

      def backspace
        start_building_number
        delete_digit
      end
    end

    state :building_number do
      def ac
        clear_everything
      end

      def digit_pressed(digit)
        @digits.add_digit(digit)
        update_display
      end

      def handle_operation(next_operation)
        calculate_answer
        @next_operation = next_operation
        number_completed
        update_display
      end

      def backspace
        delete_digit
      end
    end
  end

  def c
    @digits.clear
    update_display
  end

  (0..9).each do |digit|
    define_method(:"n#{digit}") do
      digit_pressed(digit.to_s)
    end
  end

  def plus_minus
    @digits.toggle_sign
    update_display
  end

  def plus
    handle_operation(:do_plus)
  end

  def minus
    handle_operation(:do_minus)
  end

  def times
    handle_operation(:do_times)
  end

  def divide_by
    handle_operation(:do_divide_by)
  end

  def equals
    handle_operation(:do_nothing)
    update_display
  end

  def m_plus
    @memory += @digits.to_number
  end

  def m_minus
    @memory -= @digits.to_number
  end

  def mr
    @digits.read_in_number(@memory)
    update_display
  end

  private

  def calculate_answer
    @intermediate_calculation = send(@next_operation)
    read_intermediate_calculation_into_buffer
  end

  def store_number
    @intermediate_calculation = current_display_number
  end

  def clear_everything
    clear_buffer
    n0
    number_completed
    update_display
  end

  def clear_buffer
    @digits.clear
  end

  def delete_digit
    @digits.delete_digit
    update_display
  end

  def update_current_number
    @intermediate_calculation = current_display_number
  end

  def update_display
    @display.update(@digits.to_s)
  end

  def read_intermediate_calculation_into_buffer
    @digits.read_in_number(@intermediate_calculation)
  end

  def current_display_number
    @digits.to_number
  end

  # Operation implementations

  def do_plus
    @intermediate_calculation + current_display_number
  end

  def do_minus
    @intermediate_calculation - current_display_number
  end

  def do_times
    @intermediate_calculation * current_display_number
  end

  def do_divide_by
    @intermediate_calculation / current_display_number
  end

  def do_nothing
    current_display_number
  end
end