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

  def self.list_limit
    50
  end

  def self.list(params)
    params[:page] = 0 unless params[:page]
    if params[:option] == 'last_changed'
      Sample.joins(:location).order("timestamp DESC").limit(Sample.list_limit).offset(params[:page].to_i*Sample.list_limit)
    else
      Sample.joins(:location).order(:id).limit(Sample.list_limit).offset(params[:page].to_i*Sample.list_limit)
    end
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
      self.location ||= instrument.location
    end
  end

  def set_timezone
    if timezone.present?
      self.instrument.user.update_attribute :timezone, timezone
    end
  end
end
