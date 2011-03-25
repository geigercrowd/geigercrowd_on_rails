class Sample < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :location
  has_one :user, through: :instrument
  accepts_nested_attributes_for :location
  validates_presence_of :location
  attr_accessor :timezone
end
