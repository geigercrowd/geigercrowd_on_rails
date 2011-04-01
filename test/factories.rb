Factory.define :user do |u|
  u.real_name "John Doe"
  u.screen_name "john_doe"
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

Factory.define :sample do |s|
  s.value 1.2345
  s.sequence(:timestamp) { DateTime.now }
  s.association :instrument
  s.association :location
end

Factory.define :data_type do |d|
  d.name "foo per second"
  d.si_unit "foo/s"
end

Factory.define :location do |l|
  l.latitude 1.23456789
  l.longitude 1.23456789
end

Factory.define :data_source do |ds|
  ds.name 'Saga and Nagasaki 2'
  ds.url "#{Rails.root}/test/html/saga1.html"
  ds.parser_class 'Scraper::BousaiParser'
  ds.update_interval 3600
end