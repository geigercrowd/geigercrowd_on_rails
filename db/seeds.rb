# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


units = [ { si_unit: "Gy/h", name: "gray per hour" },
          { si_unit: "Sv/h", name: "Sievert per hour" } ]

DataType.delete_all
DataType.create(units)


sources = [
{
  :id => 1,
  :name => 'Realtime radiation data provided by the japanese Ministry of Education, Culture, Sports, Science and Technology (MEXT)',
  :short_name => 'MEXT',
  :url => 'http://www.bousai.ne.jp/eng/index.html',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
  :options => { :urls => ["http://www.bousai.ne.jp/eng/speedi/pref.php?id=01", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=02", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=04", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=07", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=08", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=14", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=15", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=17", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=18", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=22", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=27", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=31", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=32", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=38", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=41", "http://www.bousai.ne.jp/eng/speedi/pref.php?id=46"]}
},
=begin
{ 
  :id => 20,
  :name => 'Hokkaido Plant',
  :url => 'http://www.genshi.pref.hokkaido.jp/NewHatuden_H.html',
  :parser_class => 'MapParser',
  :update_interval => 3600,
  :options => {:parse_item => "//table", :parse_options => [{:location_name => "Third left"}, nil, {:location_name => "Fifth right"}, nil,
                                                         {:location_name => "Sixth right"}, nil, {:location_name => "Sixth left"},
                                                         nil, {:location_name => "First left"}, nil, {:location_name => "Fourth left"},
                                                         {:location_name => "First right"}, nil, {:location_name => "Fifth left"},
                                                         {:location_name => "Third right"}, nil, {:location_name => "Second right"},
                                                         {:location_name => "Second left"}, {:location_name => "Fourth right"}, {:location_name => "Seventh right"}], 
                                      :static_options => {:value_parser_class => "nGy/h"}, 
                                      :time_options => {:regexp => "([0-9]{4})\u0094N([0-9]{2})\u008C\u008E([0-9]{2})\u0093ú\u0081@([0-9]{2})\u008E\u009E([0-9]{2})\u0095",
                                                        :mapping => {:year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => nil, :offset => "-06:00"}}}
},
{                                                 
  :id => 21,
  :name => 'Tomari Plant',
  :url => 'http://www.genshi.pref.hokkaido.jp/NewTomari_H.html',
  :parser_class => 'MapParser',
  :update_interval => 3600,
  :options => {:parse_item => "//table", :parse_options => [{:location_name => "Third right"}, {:location_name => "Second left"}, {:location_name => "First left"},
                                                         {:location_name => "First right"}, {:location_name => "Second right"}, {:location_name => "Fourth right"},
                                                         {:location_name => "Fifth right"}, {:location_name => "Sixth right"}, {:location_name => "Seventh right"}], 
                                      :static_options => {:value_parser_class => "nGy/h"}, 
                                      :time_options => {:regexp => "([0-9]{4})\u0094N([0-9]{2})\u008C\u008E([0-9]{2})\u0093ú\u0081@([0-9]{2})\u008E\u009E([0-9]{2})\u0095",
                                                        :mapping => {:year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => nil, :offset => "-06:00"}}}
}
=end
]
DataSource.delete_all
sources.each do |s|
  id = s.delete(:id)
  ds = DataSource.where(:id => id).first || DataSource.new
  ds.attributes = s
  ds.id = id
  ds.save!  
end  
  
