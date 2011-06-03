class Sample < ActiveRecord::Base

  belongs_to :instrument
  belongs_to :location
  has_one :user, through: :instrument
  has_one :data_type, through: :instrument

  attr_accessor :timezone
  accepts_nested_attributes_for :location
  validates_presence_of :timestamp
  validates_presence_of :location
  validates_presence_of :value
  before_validation :inherit_location 
  before_validation :set_timezone

  cattr_reader :per_page
  @@per_page = 30

  scope :after,  lambda { |after|  { conditions: ["timestamp >= ?", after] }}
  scope :before, lambda { |before| { conditions: ["timestamp <= ?", before] }}

  def to_json *args
    # TODO: merge-in the args
    super only: [ :id, :instrument_id, :timestamp, :value ],
      include: { location: { only: [ :latitude, :longitude, :name, :id ] }}
  end

  private

  def inherit_location
    self.location ||= instrument.location rescue nil
  end

  def set_timezone
    if timezone.present?
      self.instrument.user.update_attribute :timezone, timezone
    end
  end
end
