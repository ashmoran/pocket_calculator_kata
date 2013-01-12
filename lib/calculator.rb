require 'state_machine'
require 'facets/enumerable'

class Calculator
  def initialize(dependencies)
    @display = dependencies.fetch(:display)

    @digits                   = [ ]
    @intermediate_calculation = nil
    @next_operation           = :do_nothing

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
        clear_display
        add_digit(digit)
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
        add_digit(digit) if @digits.length < 10
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
    clear_display
    add_digit("0")
    update_display
  end

  (0..9).each do |digit|
    define_method(:"n#{digit}") do
      digit_pressed(digit.to_s)
    end
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
  end

  private

  def calculate_answer
    @intermediate_calculation = send(@next_operation)
    display_intermediate_calculation
  end

  def store_number
    @intermediate_calculation = current_number
  end

  def restore_current_number_to_buffer
    @digits
  end

  def clear_everything
    clear_display
    n0
    number_completed
    update_display
  end

  def clear_display
    @digits = [ ]
  end

  def add_digit(digit)
    @digits << digit
  end

  def delete_digit
    @digits.pop
    add_digit("0") if @digits.empty?
    update_display
  end

  def update_current_number
    @intermediate_calculation = current_number
  end

  def update_display
    @display.update(@digits.join)
  end

  def display_intermediate_calculation
    @digits = @intermediate_calculation.to_s.chars.to_a
  end

  def current_number
    @digits.reverse.map_with_index { |digit, index| digit.to_i * 10**index }.sum
  end

  # Operation implementations

  def do_plus
    @intermediate_calculation + current_number
  end

  def do_minus
    @intermediate_calculation - current_number
  end

  def do_times
    @intermediate_calculation * current_number
  end

  def do_divide_by
    @intermediate_calculation / current_number
  end

  def do_nothing
    current_number
  end
end