require_relative '../test_helper'

class LocationTest < ActiveSupport::TestCase
  context "A Location" do
    setup do 
      @location = Factory :location
      Resque.reset!
    end
    
    should "enqueue a geolocation job if latitude changed" do
      @location.latitude = 1
      @location.save
      assert_queued(Geocode, [@location.id])
    end
    should "enqueue a geolocation job if longitude changed" do
      @location.longitude = 1
      @location.save
      assert_queued(Geocode, [@location.id])
    end
    should "enqueue a geolocation job if latitude and longitude changed" do
      @location.longitude = 1
      @location.latitude = 1
      @location.save
      assert_queued(Geocode, [@location.id])
    end
    should "not enqueue a geolocation job if neither latitude nor longitude changed" do
      @location.name = "other"
      @location.save
      assert_not_queued(Geocode, [@location.id])
    end
  end


end
