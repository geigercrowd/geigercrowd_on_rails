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
  validates_presence_of :instrument
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

  def self.search params
    options = params[:options] || []
    options = options.split(",") if options.is_a?(String)

    locations = Location
    locations = locations.select "id"
    locations = locations.geo_scope origin: params[:location]

    return [] if locations.empty?

    locations = locations.order :distance
    locations = locations.map { |l| l.id }

    order = "case "
    locations.each_with_index { |l,i| order << "when location_id = #{l} then #{i} " }
    order << "end, timestamp desc, instrument_id"

    @samples = Sample
    @samples = @samples.select('distinct on (instrument_id) *') unless options.include?("history")
    @samples = @samples.where [ "location_id in (?)", locations ]
    @samples = @samples.after(params[:after]) if params[:after].present?
    @samples = @samples.before(params[:before]) if params[:before].present?
    @samples = Sample.from "(#{@samples.to_sql}) as samples"
    @samples = @samples.includes [ :data_type, :instrument, :location ]
    @samples = @samples.order order
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
