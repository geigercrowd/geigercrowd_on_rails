source 'http://rubygems.org'

gem 'rake', '~> 0.8.7' # TODO; remove this line after getting rake 0.9.x to work
gem 'pg'
gem 'postgis_adapter'
gem 'rails'
gem 'sqlite3'
gem 'devise'
gem 'haml'
gem 'hpricot'
gem 'ruby_parser'
gem 'jquery-rails'
gem 'breadcrumbs_on_rails'
gem 'resque'
gem 'resque-scheduler'
gem 'responders'
gem 'will_paginate'
gem 'geokit-rails3',        git: "git://github.com/mcmire/geokit-rails3.git",
                            branch: "fix_find_through"

group :development, :test do
  gem 'silent-postgres'
  gem 'apirunner'
end

group :test do
  gem 'ruby-debug19'
  gem 'shoulda'
  gem 'mocha'
  gem 'factory_girl_rails'
  gem 'simplecov', '~> 0.4.1', :require => false
  gem 'fakeweb'
  gem 'resque_unit'
end
