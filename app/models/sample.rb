class Sample < ActiveRecord::Base

  belongs_to :instrument
  belongs_to :location
  has_one :user, through: :instrument
  has_one :data_type, through: :instrument
  accepts_nested_attributes_for :location
  attr_accessor :timezone
  validates_presence_of :timestamp
  validates_presence_of :location
  validates_presence_of :value
  before_validation :check_location 
  before_validation :set_timezone

  ROWS_PER_PAGE = 50

  scope :after,  lambda { |after|  { conditions: ["timestamp > ?", after] }}
  scope :before, lambda { |before| { conditions: ["timestamp < ?", before] }}
  scope :latest, { select: "distinct on (instrument_id) *", order: "instrument_id, timestamp desc" }
  scope :nearby, lambda { |place|
    place = place.downcase
    { joins:      :location,
      conditions: "lower(locations.country) like '%#{place}%' or " +
                  "lower(locations.city) like '%#{place}%' or " +
                  "lower(locations.province) like '%#{place}%'" }
  }
  #scope :all, order: "timestamp desc"

  def to_json *args
    # TODO: merge-in the args
    super only: [ :id, :instrument_id, :timestamp, :value ],
      include: { location: { only: [ :latitude, :longitude, :name, :id ] }}
  end

  private

  def check_location
    if location
      # i do not see how this is useful
      #if location.latitude.blank? && location.longitude.blank?
      #  location = nil
      #end
      if instrument.location_id && instrument.location_id != location_id
        self.errors.add(:location_id, :invalid)
      end
    else
      self.location ||= instrument.location rescue nil
    end
  end

  def set_timezone
    if timezone.present?
      self.instrument.user.update_attribute :timezone, timezone
    end
  end
end
