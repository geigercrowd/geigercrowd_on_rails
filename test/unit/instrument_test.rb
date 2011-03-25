require_relative '../test_helper'

class InstrumentTest < ActiveSupport::TestCase
  context "instrument" do
    should_validate_presence_of :location

    should "accept nested attributes for location" do
      instrument = Factory.build(:instrument, location: nil)
      location = Factory.build(:location)
      assert_difference('Instrument.count') do
        Instrument.create instrument.attributes.merge(location_attributes: location.attributes)
      end
      assert_equal Location.first, Instrument.first.location
    end
  end
end
