require_relative '../test_helper'

class SampleTest < ActiveSupport::TestCase
  context "sample" do
    setup do
      @sample = Factory :sample
    end

    should_validate_presence_of :location

    should "belong to a user through an instrument" do
      assert_equal @sample.instrument.user, @sample.user
      assert_equal @sample, @sample.instrument.user.samples.first
    end

    should "accept nested attributes for location" do
      sample = Factory.build(:sample, location: nil)
      location = Factory.build(:location)
      assert_difference('Sample.count') do
        Sample.create sample.attributes.merge(location_attributes: location.attributes)
      end
      assert_equal Location.first, Sample.first.location
    end

  end
end
