namespace :apirunner do
  desc "Setup the development database to run apirunner"
  task :setup => :environment do
    if Rails.env == 'production'
      puts "Do not run this task in production!"
      return
    end
    if u = User.where(:id => 1).first
      u.id = 1
      u.authentication_token = 'APITOKEN'
      u.timezone = nil
      u.confirm!
      u.save!
    else
      u = User.new(:email => 'apirunner@local.de', :password => '123456', :password_confirmation => '123456')
      u.id = 1
      u.email = 'a' + u.email
      u.timezone = nil
      u.save!
      u.authentication_token = 'APITOKEN'
      u.confirm!
      u.save!
    end
    i = Instrument.find(33) rescue Instrument.new(:model => 'apirunner')
    i.user_id = 1
    i.location_id = Location.find(1).id rescue Location.create!(:name => 'ApiRunner', :latitude => 0, :longitude => 0).id
    i.id = 33
    i.save!
    i = Instrument.find(34) rescue Instrument.new(:model => 'apirunner')
    i.user_id = 2
    i.location_id = Location.find(2).id rescue Location.create!(:name => 'ApiRunner', :latitude => 0, :longitude => 0).id
    i.id = 34
    i.save!
  end
end