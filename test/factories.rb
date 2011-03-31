Factory.define :user do |u|
  u.real_name "John Doe"
  u.screen_name "john_doe"
  u.sequence(:email) { |i| "johnny#{i}@example.com" }
  u.password "secret"
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
