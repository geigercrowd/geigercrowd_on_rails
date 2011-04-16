namespace :utilities do
  desc "Imports the locations for the data imported from bousai.jp.ne"
  task :import_bousai_locations => :environment do
    CSV.open(Rails.root + "test/html/locations.csv").each_with_index do |row, i|
      l = Location.where(:name => row[0]).first
      l.latitude = row[1]
      l.longitude = row[2]
      l.save
    end
  end
  
  desc "Scrapes data from every DataSource"
  task :scrape => :environment do
    DataSource.all.each do |ds|
      ds.fetch
    end
  end
end