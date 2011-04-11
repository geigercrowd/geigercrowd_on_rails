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

ActiveRecord::Schema.define(:version => 20110411142337) do

  create_table "data_sources", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "parser_class"
    t.integer  "update_interval"
    t.integer  "instrument_id"
    t.text     "options"
    t.datetime "fetched_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "si_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instruments", :force => true do |t|
    t.integer  "data_type_id"
    t.integer  "user_id"
    t.string   "model"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "error"
    t.float    "deadtime"
    t.integer  "location_id"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_source_id"
    t.string   "country"
    t.string   "city"
    t.string   "province"
  end

  add_index "locations", ["data_source_id"], :name => "index_locations_on_data_source_id"

  create_table "samples", :force => true do |t|
    t.integer  "instrument_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "timestamp"
    t.integer  "location_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                       :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "screen_name"
    t.string   "real_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                               :default => false, :null => false
    t.string   "timezone"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
