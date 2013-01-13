require 'state_machine'
require 'facets/enumerable'

require_relative 'digit_buffer'

class Calculator
  def initialize(dependencies)
    @display  = dependencies.fetch(:display)
    @digits   = dependencies.fetch(:digit_buffer, DigitBuffer.new(size: 10))

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

      def operation_chosen(next_operation)
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

      def operation_chosen(operation)
        perform_queued_operation
        @next_operation = operation
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

  def point
    @digits.point
  end

  def plus_minus
    @digits.toggle_sign
    update_display
  end

  def plus
    operation_chosen(:do_plus)
  end

  def minus
    operation_chosen(:do_minus)
  end

  def times
    operation_chosen(:do_times)
  end

  def divide_by
    operation_chosen(:do_divide_by)
  end

  def equals
    operation_chosen(:do_nothing)
    update_display
  end

  def m_plus
    @memory += @digits.to_number
    number_completed
  end

  def m_minus
    @memory -= @digits.to_number
    number_completed
  end

  def mr
    @digits.read_in_number(@memory)
    update_display
  end

  def mc
    @memory = 0
  end

  private

  def clear_everything
    clear_buffer
    number_completed
    update_display
  end

  def clear_buffer
    @digits.clear
  end

  def update_display
    @display.update(@digits.to_s)
  end

  def number_completed
    @intermediate_calculation = buffer_number
    super
  end

  def buffer_number
    @digits.to_number
  end

  def perform_queued_operation
    @intermediate_calculation = send(@next_operation)
    @digits.read_in_number(@intermediate_calculation)
  end

  def delete_digit
    @digits.delete_digit
    update_display
  end

  # Operation implementations

  def do_plus
    @intermediate_calculation + buffer_number
  end

  def do_minus
    @intermediate_calculation - buffer_number
  end

  def do_times
    @intermediate_calculation * buffer_number
  end

  def do_divide_by
    @intermediate_calculation / buffer_number
  end

  def do_nothing
    buffer_number
  end
end