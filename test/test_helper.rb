ENV["RAILS_ENV"] = "test"
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# FIXME figure out a way to get the same date format
def delete_dates(data) 
  ['created_at', 'updated_at', 'timestamp', 'location'].each do |key|
    data.delete key if data[key]
  end
  data
end
