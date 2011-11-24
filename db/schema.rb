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

ActiveRecord::Schema.define(:version => 20111124061121) do

  create_table "additional_infos", :force => true do |t|
    t.integer  "user_id",                           :null => false
    t.boolean  "gender",          :default => true
    t.integer  "age"
    t.string   "location"
    t.string   "favourite_genre"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "band_invitations", :force => true do |t|
    t.integer  "band_id"
    t.integer  "user_id"
    t.string   "email"
    t.string   "token"
    t.boolean  "access_level", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "band_users", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.integer  "band_id"
    t.integer  "access_level"
    t.boolean  "is_deleted",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bands", :force => true do |t|
    t.string   "name"
    t.string   "genre"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "topic"
    t.text     "body"
    t.integer  "received_messageable_id"
    t.string   "received_messageable_type"
    t.integer  "sent_messageable_id"
    t.string   "sent_messageable_type"
    t.boolean  "opened",                     :default => false
    t.boolean  "recipient_delete",           :default => false
    t.boolean  "sender_delete",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "recipient_permanent_delete", :default => false
    t.boolean  "sender_permanent_delete",    :default => false
  end

  add_index "messages", ["ancestry"], :name => "index_messages_on_ancestry"
  add_index "messages", ["sent_messageable_id", "received_messageable_id"], :name => "acts_as_messageable_ids"

  create_table "payment_infos", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.string   "card_type"
    t.string   "name_on_card"
    t.string   "expire_month"
    t.string   "expire_year"
    t.string   "card_number"
    t.string   "security_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "album_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "profile_pics", :force => true do |t|
    t.integer  "user_id",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "userid"
  end

  create_table "user_posts", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "post"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                              :null => false
    t.string   "fname",                                              :null => false
    t.string   "lname",                                              :null => false
    t.string   "crypted_password"
    t.string   "salt"
    t.boolean  "account_type",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
  end

  add_index "users", ["activation_token"], :name => "index_users_on_activation_token"
  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_users_on_last_logout_at_and_last_activity_at"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
