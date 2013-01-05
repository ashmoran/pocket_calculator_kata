class Calculator
  def initialize(dependencies)
    @display = dependencies.fetch(:display)
  end

  def ac
    @display.update("0")
  end
end