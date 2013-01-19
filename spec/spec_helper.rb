require 'ap'

module PocketCalculatorHelper
  BUTTON_METHODS = {
    :ac         => :ac,
    :c          => :c,
    :eq         => :equals,
    :+          => :plus,
    :-          => :minus,
    :*          => :times,
    :/          => :divide_by,
    :sqrt       => :square_root,
    :plus_minus => :plus_minus,
    :m_plus     => :m_plus,
    :m_minus    => :m_minus,
    :mr         => :mr,
    :mc         => :mc,
    0           => :n0,
    1           => :n1,
    2           => :n2,
    3           => :n3,
    4           => :n4,
    5           => :n5,
    6           => :n6,
    7           => :n7,
    8           => :n8,
    9           => :n9,
    :point      => :point,
    :backspace  => :backspace
  }

  def press(*buttons)
    buttons.each do |button|
      subject.send(BUTTON_METHODS.fetch(button))
    end
  end
end

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
end
