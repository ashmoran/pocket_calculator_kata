require 'state_machine'
require 'facets/enumerable'

class Calculator
  def initialize(dependencies)
    @display = dependencies.fetch(:display)
    @digits = [ ]
    @intermediate_calculation = nil
    super()
  end

  state_machine initial: :building_number do
    event :start_building_number do
      transition :waiting_for_new_number => :building_number
    end

    event :number_completed do
      transition :building_number => :waiting_for_new_number
    end

    before_transition :building_number => :waiting_for_new_number, do: :store_number

    state :waiting_for_new_number do
      def digit_pressed(digit)
        clear_display
        add_digit(digit)
        update_display
        start_building_number
      end
    end

    state :building_number do
      def digit_pressed(digit)
        add_digit(digit) if @digits.length < 10
        update_display
      end
    end
  end

  def ac
    n0
    number_completed
    update_display
  end

  (0..9).each do |digit|
    define_method(:"n#{digit}") do
      digit_pressed(digit.to_s)
    end
  end

  def plus
    calculate_answer
    number_completed
    update_display
  end

  def equals
    calculate_answer
    number_completed
    update_display
  end

  private

  def calculate_answer
    @intermediate_calculation = @intermediate_calculation + current_number
    display_intermediate_calculation
  end

  def store_number
    @intermediate_calculation = current_number
  end

  def clear_display
    @digits = [ ]
  end

  def add_digit(digit)
    @digits << digit
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
end