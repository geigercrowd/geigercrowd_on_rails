class Location < ActiveRecord::Base
	belongs_to :user
        has_many :instruments
        has_many :samples
end
