class DataType < ActiveRecord::Base
  has_many :instruments
  has_many :samples, through: :instruments
  validates_presence_of :si_unit
  validates_uniqueness_of :si_unit, case_sensitive: false
end
