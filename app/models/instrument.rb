class Instrument < ActiveRecord::Base
  belongs_to :origin, polymorphic: true
  belongs_to :user,  :class_name => "User",
                     :foreign_key => "origin_id"
  belongs_to :data_type
  belongs_to :location
  has_many :samples
  accepts_nested_attributes_for :location
  before_validation :on_location_change
  attr_accessor :new_location

  validates_presence_of :model

  scope :after,  lambda { |after|  { conditions: ["updated_at > ?", after] }}
  scope :before, lambda { |before| { conditions: ["updated_at < ?", before] }}
  scope :latest, { order: "updated_at desc" }
  scope :page, lambda { |page|
    page = page.to_i
    page -= 1
    page = nil if page < 0
    { limit: ROWS_PER_PAGE, offset: (page.presence || 0) * ROWS_PER_PAGE }
  }

  ROWS_PER_PAGE = 50

  def to_json *args
    # TODO: merge-in the args
    super only: [ :id, :data_type_id, :model, :notes, :error, :deadtime, :updated_at ],
      include: { location: { only: [ :latitude, :longitude, :name, :id ] }}
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
