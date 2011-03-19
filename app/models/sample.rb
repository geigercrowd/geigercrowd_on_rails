class Sample < ActiveRecord::Base
  belongs_to :instrument
  belongs_to: :location
  attr_accessor :timezone
end
