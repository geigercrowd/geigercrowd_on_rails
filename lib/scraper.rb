# encoding: UTF-8
#
# Scraper (nullisnil@gmail.com)
#

module Scraper
  # To hold the generated data
  class Data
    attr_accessor :location_name, :location_admin_1, :value, :value_type, :wind_direction, :wind_velocity,
                  :wind_velocity_unit, :precipitation, :precipitation_unit, :date_time
    def initialize(attributes=nil)
      if !attributes.nil?
        self.attributes=attributes
      end
    end
    
    def attributes=(new_attributes)
      return unless new_attributes.is_a?(Hash)
      attributes = new_attributes.stringify_keys

      attributes.each do |k, v|
        respond_to?("#{k}=") ? send("#{k}=", v) : raise("unknown attribute: #{k}")
      end
    end
  end
  
  # Generic parser 
  #
  class GenericParser
    attr_accessor :doc, :data, :doc_date
    
    def initialize(url)
      self.data = []
      @value_type = nil
      @wind_velocity_unit = nil
      @precipitation_unit = nil
      @rows_xpath = nil
      @column_xpath = nil
      @time = nil

      f = open(url)
      f.rewind
      self.doc = Hpricot(Iconv.conv('UTF-8//IGNORE', (f.charset rescue 'UTF-8'), f.readlines.join("\n")))
    end
    
    def parse_time
      # did not find a better way to set any none matched time part to zero
      time = Hash.new(0)
      match = self.doc.inner_text.match(@time[:regexp])
      match.names.each do |name|
        time[name.to_sym] = match[name]
      end
      self.doc_date = Time.new(time[:year], time[:month], time[:day], time[:hour], time[:minute], time[:second], @time[:offset])
    end
    
    def parse
      self.parse_time
      
      self.doc.search(@rows_xpath).each do |row|
        columns = row.search(@column_xpath)
        self.data << Scraper::Data.new(:location_name => columns[1].inner_text.strip, :value => self.handle_undefined(columns[2].inner_text), 
                                       :precipitation => self.handle_undefined(columns[5].inner_text), :wind_direction => self.handle_wind_direction(columns[3].inner_text), 
                                       :wind_velocity => self.handle_undefined(columns[4].inner_text), :value_type => @value_type, :wind_velocity_unit => @wind_velocity_unit,
                                       :precipitation_unit => @precipitation_unit, :date_time => self.doc_date)
      end
      self.data
    end
  end
  
  # Specific parser for the reports on bousai.ne.jp
  #
  # Arguments
  # * URL
  # Returns
  # * Array of Scraper::Data
  class BousaiParser < GenericParser
    require 'open-uri'
    require 'iconv'
    
    # Params:
    # * URL
    # * Options ( :time_xpath => <XPath to the html element holding the time of the messurement>, :)
    def initialize(url)
      super(url)
      @value_type = "nGy/h"
      @wind_velocity_unit = "m/s"
      @precipitation_unit = "mm"
      @rows_xpath = '//tr[@bgcolor=#DAEDE9]'
      @column_xpath = '/td'
      @time = { :regexp => "(?<year>[0-9]{4})/(?<month>[0-9]{2})/(?<day>[0-9]{2}) (?<hour>[0-9]{2}):(?<minute>[0-9]{2})", :offset => '-06:00' }
    end
    
    def handle_undefined(value)
      value == '---' ? nil : value.to_f
    end
    
    def handle_wind_direction(value)
      value.strip
    end
  end
=begin
  class MapParser
    
    require 'open-uri'
    require 'iconv'
    
    attr_accessor :doc, :mapping, :type, :sort_by_style, :static_data, :time_regexp, :doc_date
    
    # Creates a MapParser, which is used for pages similar to http://www.genshi.pref.hokkaido.jp/NewHatuden_H.html
    #
    # Describe the Map using the URL and the tag which contains the data.
    # For each location in the Map describe the name. Use the same order like the HTML document has it.
    # To Ignore matches use "nil" to describe the data field.
    # If the value_type changes for the items describe the location like {:location_name => "Name", :value_type => "nGy/h"}
    # else use :value_type in the static data.
    # For Time parsing options see Scraper::Data.time
    #  
    # Scraper::MapParser.new("http://www.genshi.pref.hokkaido.jp/NewHatuden_H.html", "//table", 
    #          [{:location_name => "Third left"}, nil, {:location_name => "Fifth right"}, nil,
    #            {:location_name => "Sixth right"}, nil, {:location_name => "Sixth left"},
    #            nil, {:location_name => "First left"}, nil, {:location_name => "Fourth left"},
    #            {:location_name => "First right"}, nil, {:location_name => "Fifth left"},
    #            {:location_name => "Third right"}, nil, {:location_name => "Second right"},
    #            {:location_name => "Second left"}, {:location_name => "Fourth right"}, {:location_name => "Seventh right"}], 
    #            {:value_type => "nGy/h"}, 
    #            {:regexp => "([0-9]{4})\u0094N([0-9]{2})\u008C\u008E([0-9]{2})\u0093ú\u0081@([0-9]{2})\u008E\u009E([0-9]{2})\u0095",
    #            :mapping => {:year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => nil, :offset => "-06:00"}})
    #
    # Japanese Characters may be tricky: 2011\u0094N03\u008C\u008E20\u0093ú\u0081@22\u008E\u009E40\u0095ª (An example date) which is displayed in the browser as 2011年03月20日　22時30分
    # time_regexp = "([0-9]{4})\u0094N([0-9]{2})\u008C\u008E([0-9]{2})\u0093ú\u0081@([0-9]{2})\u008E\u009E([0-9]{2})\u0095" can be used for this
    def initialize(url, type, mapping = [], static_data={}, time={ :regexp => "[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}" }, sort_by_style=false)
      f = open(url)
      f.rewind
      self.doc = Hpricot(Iconv.conv('UTF-8//IGNORE', f.charset, f.readlines.join("\n")))
      self.type = type
      self.mapping = mapping
      self.static_data = static_data
      self.sort_by_style = sort_by_style
      time[:value] = self.doc.inner_text.match(time[:regexp])
      self.doc_date = time
    end
    
    # Parse the style attributes like
    # position:absolute; top:132; left:23;
    def parse_style_attribute(style)
      params = {}
      style.split(";").each do |s| 
        param = s.strip.split(":")
        params[param[0].to_sym] = param[1]
      end
      return params
    end
    
    # TODO: Allow a few pixels difference
    def sort_by_style_attribute
      items = self.doc.search(self.type)
      # Sort left to right
      items.sort_by {|item| parse_style_attribute(item['style'])[:left].to_i }
      # Sort top to down
      items.sort_by {|item| parse_style_attribute(item['style'])[:top].to_i }
    end
    
    def parse
      data = []
      if self.sort_by_style
        items = sort_by_style_attribute
      else
        items = self.doc.search(self.type)
      end
      self.mapping.each_index do |i|
        if !self.mapping[i].nil?
          data << Data.new({:location_name => self.mapping[i][:location_name], :value => items[i].inner_text.strip, 
                            :value_type => self.mapping[i][:value_type], :date_time => self.doc_date}.merge(self.static_data))
        end
      end
      return data
    end
  end
=end
end