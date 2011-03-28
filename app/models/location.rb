class Location < ActiveRecord::Base
  belongs_to :user
  has_many :instruments
  has_many :samples
  validates_presence_of :latitude
  validates_presence_of :longitude
end
