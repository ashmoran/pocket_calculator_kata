require 'state_machine'

class Calculator
  def initialize(dependencies)
    @display = dependencies.fetch(:display)
    @digits = [ ]
    super()
  end

  state_machine initial: :waiting_for_new_number do
    event :start_building_number do
      transition :waiting_for_new_number => :building_number
    end

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
    add_digit("0") # change me
    update_display
  end

  (0..9).each do |digit|
    define_method(:"n#{digit}") do
      digit_pressed(digit.to_s)
    end
  end

  private

  def clear_display
    @digits = [ ]
  end

  def add_digit(digit)
    @digits << digit
  end

  def update_display
    @display.update(@digits.join)
  end
end