Factory.define :user do |u|
  u.real_name "John Doe"
  u.sequence(:screen_name) { |i| "johndoe#{i}" }
  u.sequence(:email) { |i| "johnny#{i}@example.com" }
  u.password "secret"
  u.confirmed_at { DateTime.now }
end

Factory.define :admin, parent: :user do |u|
  u.admin true
end

Factory.define :instrument do |i|
  i.model "Kaleidoscope"
  i.association :data_type
  i.association :location
  i.association :user
end

Factory.define :instrument_sequence, parent: :instrument do |i|
  i.sequence(:model) { |i| "Instrument #{i}" }
  i.sequence(:updated_at) { |i| DateTime.now - (10-i).minutes }
end

Factory.define :sample do |s|
  s.value 1.2345
  s.timestamp { DateTime.now }
  s.association :instrument
end

Factory.define :data_type do |d|
  d.name "foo per second"
  d.si_unit "foo/s"
end

Factory.define :location do |l|
  l.latitude 1.23456789
  l.longitude 1.23456789
end

Factory.define :other_location, parent: :location do |l|
  l.latitude 2.23456789
  l.longitude 2.23456789
end

Factory.define :data_source do |ds|
  ds.name 'Saga and Nagasaki 2'
  ds.url "#{Rails.root}/test/html/saga1.html"
  ds.parser_class 'Scraper::BousaiParser'
  ds.update_interval 3600
end
