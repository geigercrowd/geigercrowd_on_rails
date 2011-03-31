class DataType < ActiveRecord::Base
  has_many :instruments
  has_many :samples, through: :instruments
end
