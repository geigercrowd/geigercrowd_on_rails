class Location < ActiveRecord::Base
  has_many :samples
end
