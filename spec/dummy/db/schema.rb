# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130419213206) do

  create_table "soc_imp_photo_tags", :force => true do |t|
    t.integer  "photo_id",                     :null => false
    t.string   "text",                         :null => false
    t.boolean  "original",   :default => true, :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "soc_imp_photo_tags", ["photo_id"], :name => "index_soc_imp_photo_tags_on_photo_id"

  create_table "soc_imp_photos", :force => true do |t|
    t.string   "file",                                :null => false
    t.text     "caption"
    t.string   "user_screen_name"
    t.string   "user_full_name"
    t.string   "user_id"
    t.string   "service",                             :null => false
    t.string   "image_service"
    t.string   "post_id"
    t.string   "post_url"
    t.boolean  "approved",         :default => false, :null => false
    t.integer  "position",         :default => 0,     :null => false
    t.integer  "program_id",                          :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "soc_imp_photos", ["program_id"], :name => "index_soc_imp_photos_on_program_id"

  create_table "soc_imp_programs", :force => true do |t|
    t.string   "name"
    t.boolean  "import_active"
    t.string   "facebook_access_token"
    t.string   "instagram_client_id"
    t.string   "tumblr_consumer_key"
    t.datetime "last_imported_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

end
