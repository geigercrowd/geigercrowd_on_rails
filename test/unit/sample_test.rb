require_relative '../test_helper'

class SampleTest < ActiveSupport::TestCase
  context "sample" do
    setup do
      @sample = Factory :sample
      @instrument = @sample.instrument
      @user = @sample.user
    end

    context "relationships" do
      should "belong to instrument" do
        instrument = @sample.instrument
        assert_equal [ @sample ], instrument.samples
      end

      should "have a user" do
        timestamp = DateTime.now
        sample = @instrument.samples.create value: 1.2345, timestamp: timestamp
        assert sample.valid?
        assert @instrument.user.samples.include? sample
        assert_equal @instrument.user, sample.user
      end

      should "have a data type" do
        assert_equal @instrument.data_type, @sample.data_type
      end
    end

    should "take its instrument's location if not specified" do
      new_sample = @instrument.samples.create value: 12.34, timestamp: DateTime.now
      assert_valid new_sample
      assert_equal @instrument.location, @instrument.samples.last.location
    end
  end
end
