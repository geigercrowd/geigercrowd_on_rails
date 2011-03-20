class Instrument < ActiveRecord::Base
  belongs_to :user
  belongs_to :data_type
  belongs_to :location
  has_many :samples
end
