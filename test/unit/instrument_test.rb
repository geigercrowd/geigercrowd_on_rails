require_relative '../test_helper'

class InstrumentTest < ActiveSupport::TestCase
  context "instrument" do
    should_validate_presence_of :location
  end
end
