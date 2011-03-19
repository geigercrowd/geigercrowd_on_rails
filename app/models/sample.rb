class Sample < ActiveRecord::Base
  belongs_to :instrument
  attr_accessor :timezone
end
