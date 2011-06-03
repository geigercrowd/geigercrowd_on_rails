# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110602084354) do

  create_table "data_sources", :force => true do |t|
    t.column "name", :string
    t.column "url", :string
    t.column "parser_class", :string
    t.column "update_interval", :integer
    t.column "instrument_id", :integer
    t.column "options", :text
    t.column "fetched_at", :datetime
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "short_name", :string
  end

  add_index "data_sources", ["short_name"], :name => "index_data_sources_on_short_name"

  create_table "data_types", :force => true do |t|
    t.column "name", :string
    t.column "description", :text
    t.column "si_unit", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "instruments", :force => true do |t|
    t.column "data_type_id", :integer
    t.column "model", :string
    t.column "notes", :text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "error", :float
    t.column "deadtime", :float
    t.column "location_id", :integer
    t.column "origin_id", :integer
    t.column "origin_type", :string
  end

  add_index "instruments", ["origin_id"], :name => "index_instruments_on_origin_id"

  create_table "locations", :force => true do |t|
    t.column "name", :string
    t.column "user_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "data_source_id", :integer
    t.column "country", :string
    t.column "city", :string
    t.column "province", :string
    t.column "geometry", :point, :srid => 4326
  end

  add_index "locations", ["data_source_id"], :name => "index_locations_on_data_source_id"
  add_index "locations", ["geometry"], :name => "index_locations_on_geometry", :spatial=> true 

  create_table "samples", :force => true do |t|
    t.column "instrument_id", :integer
    t.column "value", :float
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "timestamp", :datetime
    t.column "location_id", :integer
  end

  add_index "samples", ["timestamp"], :name => "index_samples_on_timestamp"
  add_index "samples", ["instrument_id", "timestamp"], :name => "index_samples_on_timestamp_and_instrument_id"

  create_table "users", :force => true do |t|
    t.column "email", :string, :default => "", :null => false
    t.column "encrypted_password", :string, :limit => 128, :default => "", :null => false
    t.column "reset_password_token", :string
    t.column "remember_token", :string
    t.column "remember_created_at", :datetime
    t.column "sign_in_count", :integer, :default => 0
    t.column "current_sign_in_at", :datetime
    t.column "last_sign_in_at", :datetime
    t.column "current_sign_in_ip", :string
    t.column "last_sign_in_ip", :string
    t.column "confirmation_token", :string
    t.column "confirmed_at", :datetime
    t.column "confirmation_sent_at", :datetime
    t.column "screen_name", :string
    t.column "real_name", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "admin", :boolean, :default => false, :null => false
    t.column "timezone", :string
    t.column "authentication_token", :string
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
