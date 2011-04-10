class Sample < ActiveRecord::Base
  include Permissions

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

  scope :after,  lambda { |after|  { conditions: "timestamp > '#{after}'" }}
  scope :before, lambda { |before| { conditions: "timestamp < '#{before}'" }}
  scope :latest, { select: "distinct on (instrument_id) *", order: "instrument_id, timestamp desc" }
  scope :page, lambda { |page|
    page -= 1
    page = nil if page < 0
    { limit: ROWS_PER_PAGE, offset: (page.presence || 0) * ROWS_PER_PAGE }
  }

  def to_json *args
    # TODO: merge in the args
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
      if instrument.location_id != location_id
        errors.add(:location, 'cannot be set, because already set in instrument')
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
