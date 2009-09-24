# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090923220206) do

  create_table "classifies", :force => true do |t|
    t.integer  "remark_id",                               :null => false
    t.string   "word",                                    :null => false
    t.integer  "delete_flag", :limit => 1, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dictionaries", :force => true do |t|
    t.string   "word",       :null => false
    t.string   "word_type",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "generaters", :force => true do |t|
    t.string   "user_id",    :null => false
    t.string   "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remarks", :force => true do |t|
    t.string   "user_id",                                 :null => false
    t.string   "remark",                                  :null => false
    t.string   "wakati",                                  :null => false
    t.integer  "delete_flag", :limit => 1, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delete_flag", :default => false
  end

end
