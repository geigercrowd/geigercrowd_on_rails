# encoding: UTF-8
#
# Scraper (nullisnil@gmail.com)
#
# Examples:
# Single Table on a page
#
#  Scraper::TableParser.new("http://www.bousai.ne.jp/eng/speedi/pref.php?id=01", 6, {:id => "No",
#                                                                                    :value => "Rate of space dose", 
#                                                                                    :wind_direction => "Wind Direction",
#                                                                                    :location_name => "Observation office", 
#                                                                                    :wind_velocity => "Wind Velocity",
#                                                                                    :precipitation => "Precipitation"},
#                                                                                   {:location_admin_1 => "Hokkaido",
#                                                                                    :value_type => "nGy/h",
#                                                                                    :wind_velocity_unit => "m/s",
#                                                                                    :precipitation_unit => "mm"}).parse
#
# Multiple Tables on a page
#
# Scraper::TableParser.new("http://www.bousai.ne.jp/eng/speedi/pref.php?id=33", 6, {:id => "No",
#                                                                                   :value => "Rate of space dose", 
#                                                                                   :wind_direction => "Wind Direction",
#                                                                                   :location_name => "Observation office", 
#                                                                                   :wind_velocity => "Wind Velocity",
#                                                                                   :precipitation => "Precipitation"},
#                                                                                  [{:location_admin_1 => "Tottori",
#                                                                                    :value_type => "nGy/h",
#                                                                                    :wind_velocity_unit => "m/s",
#                                                                                    :precipitation_unit => "mm"},
#                                                                                   {:location_admin_1 => "Okayama",
#                                                                                    :value_type => "nGy/h",
#                                                                                    :wind_velocity_unit => "m/s",
#                                                                                    :precipitation_unit => "mm"}]).parse
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
    
    # Returns Time data as Time.
    # If your time regexp returns an array e.g. by using
    #   :regexp => "([0-9]{4})\u0094N([0-9]{2})\u008C\u008E([0-9]{2})\u0093ú\u0081@([0-9]{2})\u008E\u009E([0-9]{2})\u0095"
    # in the parser, use 
    #   :mapping => {:year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => nil, :offset => "-06:00"}
    # To map the Array to the parsed time.
    # This is not required if time is parsable by Time.parse.
    def time
      if self.date_time.length == 1 
        Time.parse(self.date_time[:value].to_s)
      else
        time = {}
        for key in self.date_time[:mapping].keys
          if key == :offset
            time[:offset] = self.date_time[:mapping][:offset]
          elsif !self.date_time[:mapping][key].nil?
            time[key] = self.date_time[:value][self.date_time[:mapping][key]]
          end
        end
        Time.new(time[:year], time[:month], time[:day], time[:hour], time[:minute], time[:second], time[:offset])
      end
    end
  end
  
  class TableParser
    require 'open-uri'
    require 'iconv'

    attr_accessor :doc, :column_count, :mapping, :column_mapping, :datas, :static_data, :doc_date
    
    # Params:
    #   * URL
    #   * Data Column amount
    #   * Mapping Hash
    #   * Static data Hash (Use an Array with a hash inside if there are multiple tables on this page)
    #   * REgexp to match date/time
    # 
    # First row needs to be table header with descriptions
    #
    # Name all mapping fields even if they are not used
    # E.g.:
    # Scraper::TableParser.new("http://www.bousai.ne.jp/eng/speedi/pref.php?id=01", 6, {:id => "No",
    #                                                                                   :value => "Rate of space dose", 
    #                                                                                   :wind_direction => "Wind Direction",
    #                                                                                   :location_name => "Observation office", 
    #                                                                                   :wind_velocity => "Wind Velocity",
    #                                                                                   :precipitation => "Precipitation"},
    #                                                                                   "[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}")
    #
    # Time Options:
    # Use a regexp to parse the time. If you create a MatchData Array use the mapping key to describe the returned Array.
    # {
    #  :regexp => "[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}",
    #  :mapping => "yyyy mm dd hh mm ss"
    # }
    
    def initialize(url, column_count=nil, mapping={}, static_data={}, time={ :regexp => "[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}" })
      f = open(url)
      f.rewind
      self.doc = Hpricot(Iconv.conv('UTF-8//IGNORE', f.charset, f.readlines.join("\n")))
      self.column_count = column_count
      self.mapping = mapping
      self.column_mapping = {}
      self.datas = []
      self.static_data = static_data
      time[:value] = self.doc.inner_text.match(time[:regexp])
      self.doc_date = time
    end
    
    # Parses the remote Website
    # Returns an Array with Scraper::Data items
    def parse
      data = []
      if self.static_data.class.name == "Hash"
        table = find_table_by_column_size if !self.column_count.nil?
        map_columns(table)
        data = process_rows(table, self.static_data)
      elsif self.static_data.class.name == "Array"
        for item in self.static_data
          table = find_table_by_column_size if !self.column_count.nil?
          map_columns(table)
          data << process_rows(table, item)
        end
      end
      return data.flatten
    end
    
    # Find Tables by column size
    def find_table_by_column_size(doc=nil)
      doc = self.doc if doc.nil?
      doc.search("//table").each {|t|
        if t.search("//table").size > 0
          puts "Found table with #{t.search("//table").size} tables" if $debug
          table = find_table_by_column_size(t)
          return table if !table.nil?
        else
          if t.search("//tr").first.search("//td").size == self.column_count
            puts "Found tr with #{t.search("//tr").first.search("//td").size} tds" if $debug
            self.doc.search(t.xpath).remove
            return t
          end
        end
      }
      return nil
    end
    
    # Map table columns of the table to the mapping
    def map_columns(table)
      counter = 0
      table.search("//tr").first.search("//td").each {|td|
        for key in self.mapping.keys
          puts "Processing #{key} with value #{self.mapping[key]}" if $debug
          if td.inner_text.include?(self.mapping[key])
            puts "Found column #{key}" if $debug
            self.column_mapping[counter] = key
            counter += 1
            self.mapping.delete(key)
            break
          end
        end
      }
    end
    
    def process_rows(table, static_data)
      rows = table.search("//tr")
      rows[1..(rows.size-1)].each {|tr|
        data = Data.new
        tds = tr.search("//td")
        
        attributes = {:date_time => self.doc_date}
        for key in self.column_mapping.keys
          if data.method_exists?(self.column_mapping[key].to_s)
            attributes[self.column_mapping[key]] = tds[key.to_i].inner_text
          end
        end
        data.attributes=attributes
        static_data.stringify_keys.each do |k, v|
          data.respond_to?("#{k}=") ? data.send("#{k}=", v) : raise("unknown attribute: #{k}")
        end
        self.datas << data
      }
      return self.datas
    end
    
  end
  
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
end