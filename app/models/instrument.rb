class Instrument < ActiveRecord::Base
  belongs_to :user
  belongs_to :data_type
  belongs_to :location
  has_many :samples
  accepts_nested_attributes_for :location
  before_validation :on_location_change
  attr_accessor :new_location

  private

  def on_location_change
    if location.present?
      if location.latitude.blank? && location.longitude.blank?
        self.location = nil
      elsif !location_id_was.nil? &&
        (location.latitude_changed? || location.longitude_changed?)

        if [ true, "true" ].include? new_location
          self.location = Location.new latitude:  location.latitude,
            longitude: location.longitude
        elsif ! [ false, "false" ].include? new_location
          errors.add :new_location, :blank
        end
      end
    end
  end
end
