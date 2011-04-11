require_relative '../test_helper'

require 'resque_unit_scheduler'

class GeocodingTest < ActiveSupport::TestCase
  context "The (reverse) Geocoder" do
    context "hannover" do
      setup do 
        @location = Factory(:location)
      end
      
      should "reverse geocode hannover" do
        FakeWeb.register_uri(:get, %r|http://api.geonames.org/|, :body => '{"geonames":[{"countryName":"Germany","adminCode1":"06","fclName":"city, village,...","countryCode":"DE","lng":9.73322153091431,"fcodeName":"seat of a first-order administrative division","distance":"0.24033","toponymName":"Hannover","fcl":"P","name":"Hanover","fcode":"PPLA","geonameId":2910831,"lat":52.3705162650448,"adminName1":"Lower Saxony","population":515140}]}')

        Geocode.perform(@location.id)
        @location.reload
        assert_equal "Hannover", @location.city
        assert_equal "Germany", @location.country
        assert_equal "Lower Saxony", @location.province
      end
      
      should "reverse geocode fukushima powerplant" do
        FakeWeb.register_uri(:get, %r|http://api.geonames.org/|, :body => '{"geonames":[{"countryName":"Japan","adminCode1":"08","fclName":"city, village,...","countryCode":"JP","lng":141.0166667,"fcodeName":"populated place","distance":"1.77544","toponymName":"Tomioka","fcl":"P","name":"Tomioka","fcode":"PPL","geonameId":2110749,"lat":37.3333333,"adminName1":"Fukushima","population":0}]}')
        Geocode.perform(@location.id)
        @location.reload
        assert_equal "Tomioka", @location.city
        assert_equal "Japan", @location.country
        assert_equal "Fukushima", @location.province
      end
      
      should "reshedule the job if the api limit has been exceeded" do
        FakeWeb.register_uri(:get, %r|http://api.geonames.org/|, :body => '{"status":{"message":"the hourly limit of 2000 credits demo has been exceeded. Please throttle your requests or use the commercial service.","value":19}}')
        Geocode.perform(@location.id)
        assert_queued_in(3601, Geocode)
      end
      should "handle errors" do
        FakeWeb.register_uri(:get, %r|http://api.geonames.org/|, :body => '{"status":{"message":"some message i cant remember.","value":10}}')
        assert_raises RuntimeError do
          Geocode.perform(@location.id)
        end
      end

    end
  end
end
