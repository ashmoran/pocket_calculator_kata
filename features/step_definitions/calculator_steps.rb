Given %r/^I have a pocket calculator$/ do
  @display    = MockDisplay.new
  @calculator = Calculator.new(display: @display)
end

Given %r/^it is turned on$/ do
  press "AC"
end

When %r/^I press "(.*?)"$/ do |keys|
  press(*keys.split(" "))
end

Then %r/^the display shows "(.*?)"$/ do |expected_display_contents|
  expect(@display.display_contents).to be == expected_display_contents
end