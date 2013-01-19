module PocketCalculatorHelper
  BUTTON_METHODS = {
    "AC" => :ac,
    "C"  => :c,
    "="  => :equals,
    "+"  => :plus,
    "-"  => :minus,
    "*"  => :times,
    "/"  => :divide_by,
    "+/-" => :plus_minus,
    "M+" => :m_plus,
    "M-" => :m_minus,
    "MR" => :mr,
    "MC" => :mc,
    "0"  => :n0,
    "1"  => :n1,
    "2"  => :n2,
    "3"  => :n3,
    "4"  => :n4,
    "5"  => :n5,
    "6"  => :n6,
    "7"  => :n7,
    "8"  => :n8,
    "9"  => :n9,
    "."  => :point,
    ">"  => :backspace
  }

  def press(*buttons)
    buttons.each do |button|
      @calculator.send(BUTTON_METHODS.fetch(button))
    end
  end
end

World(PocketCalculatorHelper)