class Instrument < ActiveRecord::Base
  belongs_to :user
  belongs_to :data_type
  has_many :samples
end
