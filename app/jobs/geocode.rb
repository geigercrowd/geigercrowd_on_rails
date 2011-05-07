require 'net/http'

module Geocode
  @queue = :geocode
  
  def self.user
    $geonames_user ||= YAML::load_file(Rails.root.to_s + '/config/database.yml')[Rails.env]['geonames_user'] rescue 'unknown'
  end
  
  def self.perform(location_id)
    location = Location.find(location_id)
    url = "http://api.geonames.org/findNearbyPlaceNameJSON?lat=#{location.latitude}&lng=#{location.longitude}&username=#{Geocode.user}"
    response = Net::HTTP.get(URI.parse(url))
    data = JSON.parse(response)
    if data['status']
      # requeue the job
      if data['status']['value'] == 19
        Resque.enqueue_in(3601, Geocode, location_id)
        return true
      end
      raise "Invalid username" if data['status']['value'] == 10
      raise "Invlid response: #{data.inspect}"
    end
    raise "Unknown json response" if !data['geonames'] && data['geonames'].length == 0
    location.country = data['geonames'][0]["countryName"]
    location.city = data['geonames'][0]["toponymName"]
    location.province = data['geonames'][0]["adminName1"]
    location.save!
    true
  end
end
  

