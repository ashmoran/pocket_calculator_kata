class MockDisplay
  def initialize
    reset_display_memory
  end

  def update(contents)
    @displayed_values << contents
  end

  def display_contents
    @displayed_values.last
  end

  def reset_display_memory
    @displayed_values = [ ]
  end
end