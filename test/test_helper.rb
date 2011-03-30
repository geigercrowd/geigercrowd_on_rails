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

