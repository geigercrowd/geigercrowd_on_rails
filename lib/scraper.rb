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
#                                                                                    :value_types => "nGy/h",
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
#                                                                                    :value_types => "nGy/h",
#                                                                                    :wind_velocity_unit => "m/s",
#                                                                                    :precipitation_unit => "mm"},
#                                                                                   {:location_admin_1 => "Okayama",
#                                                                                    :value_types => "nGy/h",
#                                                                                    :wind_velocity_unit => "m/s",
#                                                                                    :precipitation_unit => "mm"}]).parse
#

module Scraper
  # To hold the generated data
  class Data
    attr_accessor :location_name, :location_admin_1, :value, :value_types, :wind_direction, :wind_velocity,
                  :wind_velocity_unit, :precipitation, :precipitation_unit, :date_time
    def initialize()
    end
    
    def attributes=(new_attributes)
      return unless new_attributes.is_a?(Hash)
      attributes = new_attributes.stringify_keys

      attributes.each do |k, v|
        respond_to?("#{k}=") ? send("#{k}=", v) : raise("unknown attribute: #{k}")
      end

    end
    
  end
  
  class TableParser
    require 'open-uri'
    
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
    
    def initialize(url, column_count=nil, mapping={}, static_data={}, time_regexp="[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}")
      self.column_count = column_count
      self.mapping = mapping
      self.column_mapping = {}
      self.datas = []
      self.static_data = static_data
      self.doc = Hpricot(open(url))
      self.doc_date = self.doc.inner_text.match(time_regexp).to_s
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
end