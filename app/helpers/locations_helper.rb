module LocationsHelper
  def location_options locations
    locations.collect do |i|
      [ i.name, i.id ]
    end
  end
end
