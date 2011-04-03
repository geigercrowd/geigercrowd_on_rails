require_relative '../test_helper'

class InstrumentTest < ActiveSupport::TestCase
  context "instrument" do
    setup do
      @instrument = Factory :instrument
    end

    should "accept nested attributes for location" do
      assert_difference "Instrument.count" do
        Instrument.create model: "fubarator",
          location_attributes: { latitude: 1, longitude: 2 }
      end
      assert_equal 1.0, Instrument.last.location.latitude
      assert_equal 2.0, Instrument.last.location.longitude
    end

    context "location changes" do
      setup do
        @instrument.location = Factory :location
        @instrument.save
        @old_location = @instrument.location.attributes
      end

      should "create new location when new_location set to true" do
        @instrument.update_attributes new_location: "true",
          location_attributes: { id:        @old_location["id"],
                                 latitude:  @old_location["latitude"]  + 5,
                                 longitude: @old_location["longitude"] + 5 }
        assert @instrument.valid?
        assert_not_equal @old_location["id"], @instrument.location.id
        assert_equal @old_location["latitude"] + 5, @instrument.location.latitude
        assert_equal @old_location["longitude"] + 5, @instrument.location.longitude
      end

      should "update location when new_location set to false" do
        @instrument.update_attributes new_location: "false",
          location_attributes: { id:        @old_location["id"],
                                 latitude:  @old_location["latitude"]  + 5,
                                 longitude: @old_location["longitude"] + 5 }
        assert @instrument.valid?
        assert_equal @old_location["id"], @instrument.location.id
        assert_equal @old_location["latitude"] + 5, @instrument.location.latitude
        assert_equal @old_location["longitude"] + 5, @instrument.location.longitude
      end

      should "be invalid if new_location is not set" do
        @instrument.update_attributes location_attributes:
          { id:        @old_location["id"],
            latitude:  @old_location["latitude"]  + 5,
            longitude: @old_location["longitude"] + 5 }
        assert !@instrument.valid?
        assert_equal({ new_location: [I18n.t("activerecord.errors.models." +
          "instrument.attributes.new_location.blank")]}, @instrument.errors)
        @instrument.reload
        assert_equal @old_location["id"], @instrument.location.id
        assert_equal @old_location["latitude"], @instrument.location.latitude
        assert_equal @old_location["longitude"], @instrument.location.longitude
      end
    end
  end
end
