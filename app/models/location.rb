class Location < ActiveRecord::Base
  belongs_to :user
  has_many :instruments
  has_many :samples
  validates_presence_of :latitude
  validates_presence_of :longitude
  
  before_update :geocode
  # after_create { Resque.enqueue(Geocode, self.id) }
  
  acts_as_mappable default_units: :kms,
                   lng_column_name: :longitude,
                   lat_column_name: :latitude

  def geocode
    if longitude_changed? or latitude_changed? && longitude != nil && latitude != nil
      Resque.enqueue(Geocode, self.id)
    end
  end
end
