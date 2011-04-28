module LocationsHelper
  def location_options locations
    locations.collect do |i|
      [ i.name, i.id ]
    end
  end

  def format_location location
    return t('not_applicable') if location.nil?
    string = ""
    string += "#{location.city}, #{location.province}, #{location.country} (" if location.city
    string += "#{location.latitude} #{location.longitude}"
    string += ")" if location.city
    string
  end
end
