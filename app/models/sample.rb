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
  before_validation :location_from_instrument 
  before_validation :set_timezone

  private

  def location_from_instrument
    if location && location.latitude.blank? && location.longitude.blank?
      location = nil
    end
    self.location ||= instrument.location
  end

  def set_timezone
    if timezone.present?
      Time.zone = timezone
      self.instrument.user.update_attribute :timezone, Time.zone
    end
  end
end
