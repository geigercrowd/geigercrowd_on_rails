class Sample < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :location
  belongs_to :user
  attr_accessor :timezone
end
