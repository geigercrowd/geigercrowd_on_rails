# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

sources = [
{
  :id => 1,
  :name => 'Hokkaido',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=01',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 2,
  :name => 'Aomori',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=02',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 3,
  :name => 'Miyagi',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=04',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 4,
  :name => 'Fukushima',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=07',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 5,
  :name => 'Ibaraki',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=08',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 6,
  :name => 'Kanagawa',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=14',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 7,
  :name => 'Niigata',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=15',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 8,
  :name => 'Ishikawa',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=17',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 9,
  :name => 'Fukui and Kyoto',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=18',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 10,
  :name => 'Shizuoka',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=22',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 11,
  :name => 'Osaka',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=27',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 12,
  :name => 'Tottori and Okayama',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=31',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 13,
  :name => 'Shimane',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=32',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,                   
},
{ 
  :id => 14,
  :name => 'Ehime',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=38',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 15,
  :name => 'Saga and Nagasaki',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=41',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
},
{ 
  :id => 16,
  :name => 'Kagoshima',
  :url => 'http://www.bousai.ne.jp/eng/speedi/pref.php?id=46',
  :parser_class => 'Scraper::BousaiParser',
  :update_interval => 3600,
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
sources.each do |s|
  id = s.delete(:id)
  ds = DataSource.where(:id => id).first || DataSource.new
  ds.attributes = s
  ds.id = id
  ds.save!  
end  
  