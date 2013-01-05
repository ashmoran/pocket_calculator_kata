class Calculator
  def initialize(dependencies)
    @display = dependencies.fetch(:display)
  end

  def ac
    @display.update("0")
  end

  def n1
    @display.update("1")
  end
end