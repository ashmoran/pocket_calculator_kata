require 'ap'

module PocketCalculatorHelper
  def press_digits(*digits)
    digits.each do |digit|
      subject.send(:"n#{digit}")
    end
  end
  alias_method :press_digit, :press_digits
end

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
end
