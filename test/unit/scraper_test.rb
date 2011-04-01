require_relative '../test_helper'
require_relative '../../lib/scraper.rb'
class ScraperTest < ActiveSupport::TestCase
  context "BousaiParser" do
    setup do
      @data = { :name => 'Saga and Nagasaki 2',
                :url => "#{Rails.root}/test/html/saga1.html",
                :type => 'BousaiParser',
                :update_interval => 600,
                :options => { :value_type => "nGy/h",
                              :wind_velocity_unit => "m/s",
                              :precipitation_unit => "mm",
                            }
              }
      @scraped = Scraper::BousaiParser.new(@data[:url]).parse
    end
    should "run without errors and parse every row" do
      assert_equal 7, @scraped.length
    end
    
    should "parse a complete row correctly" do
      complete = @scraped.select { |x| x.location_name == 'Imamura Genkai Town'}.first
      assert_equal 'Imamura Genkai Town', complete.location_name
      assert_equal 27.0, complete.value
      assert_equal 'S', complete.wind_direction
      assert_equal 0.8, complete.wind_velocity
      assert_equal 0.0, complete.precipitation
      assert_equal Time.new(2011,04,01,06,50,0,'-06:00'), complete.date_time
    end
    
    should "parse a incomplete row correctly" do 
      complete = @scraped.select { |x| x.location_name == 'Hokawaduura Genkai Town'}.first
      assert_equal 'Hokawaduura Genkai Town', complete.location_name
      assert_equal 33.0, complete.value
      assert_equal 'calm', complete.wind_direction
      assert_equal 0.3, complete.wind_velocity
      assert_equal nil, complete.precipitation
      
    end
  end
end