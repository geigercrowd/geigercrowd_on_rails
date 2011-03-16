class DataType < ActiveRecord::Base
  has_many :samples
  has_many :instruments
end
