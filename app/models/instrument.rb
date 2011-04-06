class Instrument < ActiveRecord::Base
  belongs_to :user
  belongs_to :data_type
  belongs_to :location
  belongs_to :data_source
  has_many :samples
  accepts_nested_attributes_for :location
  before_validation :on_location_change
  attr_accessor :new_location

  def self.list_limit
    50
  end

  def self.list(params)
    params[:page] = 0 unless params[:page]
    if params[:option] == 'last_changed'
      Instrument.joins(:location).order("updated_at DESC").limit(Instrument.list_limit).offset(params[:page].to_i*Instrument.list_limit)
    else
      Instrument.joins(:location).order(:id).limit(Instrument.list_limit).offset(params[:page].to_i*Instrument.list_limit)
    end
  end

  private

  # When the associated location's coordinates are changed:
  # * creates a new location, when new_location is true,
  # * changes the existing location's coordinates when new_location is false,
  # * renders the instrument invalid when new_location is neither true nor false,
  # * sets location_id nil if the location's coordinates are both blank
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
