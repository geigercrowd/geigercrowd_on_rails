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

    context "timezone" do
      setup do
        Time.zone = "UTC"
      end

      teardown do
        timezone = ActiveSupport::TimeZone.new("Berlin")
        assert_equal timezone, Time.zone
        @instrument.user.reload
        assert_equal timezone, @instrument.user.timezone
      end

      should "be set on creation" do
        timestamp = DateTime.new 2011, 01, 01, 13, 37, 23
        sample = @instrument.samples.create value: 1.2345, 
          timestamp: timestamp, timezone: "Berlin"
        sample.reload
        assert_equal 3600, sample.timestamp.utc_offset
      end

      should "be set on creation (DST)" do
        timestamp = DateTime.new 2011, 06, 01, 13, 37, 23
        sample = @instrument.samples.create value: 1.2345, 
          timestamp: timestamp, timezone: "Berlin"
        sample.reload
        assert_equal 7200, sample.timestamp.utc_offset
      end
    end
    context "using changing timezones" do
      should "be saved correctly" do
        timestamp = '2011-04-04 20:38:22'
        sample = @instrument.samples.create value: 1.2345, 
          timestamp: timestamp, timezone: "UTC"
        sample.reload
        assert_equal '2011-04-04 20:38:22', sample.timestamp.utc.strftime('%Y-%m-%d %H:%M:%S')
        sample = @instrument.samples.create value: 1.2345, 
          timestamp: timestamp, timezone: "Berlin"
        sample.reload
        # FIXME wrong test assumption, or a real bug in the code?
        assert_equal '2011-04-04 18:38:22', sample.timestamp.utc.strftime('%Y-%m-%d %H:%M:%S')
      end
    end
  end
end
