class Location < ActiveRecord::Base
	belongs_to :user
        belongs_to :instrument
        has_many :samples
end
