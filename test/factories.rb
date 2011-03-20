Factory.define :user do |u|
  u.real_name "John Doe"
  u.screen_name "john_doe"
  u.email "john@doe.xyz"
  u.password "secret"
end

Factory.define :instrument do |i|
  i.model "Kaleidoscope"
  i.association :location
  i.association :user
  i.association :data_type
end

Factory.define :sample do |s|
  s.value 1.2345
  s.association :instrument
end

Factory.define :data_type do |d|
  d.name "foos per second"
  d.si_unit "foos/s"
end

Factory.define :location do |l|
  l.latitude 1.23456789
  l.longitude 1.23456789
end
