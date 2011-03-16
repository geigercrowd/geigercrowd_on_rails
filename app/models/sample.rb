class Sample < ActiveRecord::Base
  belongs_to :location
  belongs_to :data_type
  belongs_to :instrument
end
