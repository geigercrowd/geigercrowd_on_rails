class Sample < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :location
  has_one :user, through: :instrument
  attr_accessor :timezone
end
