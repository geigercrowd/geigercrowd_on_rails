class Location < ActiveRecord::Base
  belongs_to :user
  has_many :instruments
  has_many :samples

  attr_accessor :latitude, :longitude
  
  validates_presence_of :geometry

  before_update :geocode
  before_save :geometrize
  after_create { Resque.enqueue(Geocode, self.id) }
  
  acts_as_geom :geometry => :point

  def latitude
    @latitude || geometry.x
  end

  def longitude
    @longitude || geometry.y
  end

  private

  def geometrize
    if @latitude.present? && @longitude.present?
      self.geometry = Point.from_x_y @latitude, @longitude
    end
  end

  def geocode
    if longitude_changed? or latitude_changed? && longitude != nil && latitude != nil
      Resque.enqueue(Geocode, self.id)
    end
  end
end
