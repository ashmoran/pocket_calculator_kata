require 'spec_helper'
require_relative 'digit_buffer_contract'

require 'digit_buffer_positional'

describe DigitBufferPositional do
  subject(:buffer) { DigitBufferPositional.new(size: 5) }

  it_behaves_like "a DigitBuffer"
end
