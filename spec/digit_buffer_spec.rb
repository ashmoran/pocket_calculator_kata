require 'spec_helper'
require_relative 'digit_buffer_contract'

require 'digit_buffer'

describe DigitBuffer do
  subject(:buffer) { DigitBuffer.new(size: 5) }

  it_behaves_like "a DigitBuffer"
end