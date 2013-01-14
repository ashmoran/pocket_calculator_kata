Given %r/^I have a pocket calculator$/ do
  @display    = MockDisplay.new
  @calculator = Calculator.new(display: @display)
end

When %r/^I press "(.*?)"$/ do |key|
  press key
end

Then %r/^the display shows "(.*?)"$/ do |expected_display_contents|
  expect(@display.display_contents).to be == expected_display_contents
end