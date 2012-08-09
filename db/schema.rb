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

ActiveRecord::Schema.define(:version => 20120809104308) do

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

  create_table "artist_albums", :force => true do |t|
    t.integer  "artist_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_count",    :default => 0
    t.boolean  "disabled",       :default => false
    t.integer  "cover_image_id"
  end

  create_table "artist_invitations", :force => true do |t|
    t.integer  "artist_id"
    t.integer  "user_id"
    t.string   "email"
    t.string   "token"
    t.boolean  "access_level", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_logos", :force => true do |t|
    t.integer  "artist_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "artist_musics", :force => true do |t|
    t.integer  "artist_id"
    t.integer  "user_id"
    t.string   "album_name"
    t.string   "cover_img_file_name"
    t.string   "cover_img_content_type"
    t.integer  "cover_img_file_size"
    t.datetime "cover_img_updated_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price",                  :default => 0.0
    t.boolean  "disabled",               :default => false
    t.integer  "song_count",             :default => 0
    t.boolean  "featured",               :default => false
  end

  create_table "artist_photos", :force => true do |t|
    t.integer  "artist_album_id"
    t.integer  "user_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "caption"
  end

  create_table "artist_shows", :force => true do |t|
    t.integer  "artist_id",  :null => false
    t.date     "show_date",  :null => false
    t.string   "venue",      :null => false
    t.text     "more_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
  end

  create_table "artist_users", :force => true do |t|
    t.integer  "user_id",                            :null => false
    t.integer  "artist_id"
    t.integer  "access_level"
    t.boolean  "is_deleted",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notification_on", :default => true
  end

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.string   "genre"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio"
    t.string   "location"
    t.string   "artist_logo_url"
    t.string   "website"
    t.string   "mention_name"
    t.string   "facebook_page"
    t.string   "twitter_page"
    t.boolean  "is_member_public", :default => true
  end

  create_table "artists_genres", :id => false, :force => true do |t|
    t.integer "artist_id", :null => false
    t.integer "genre_id",  :null => false
  end

  create_table "connections", :force => true do |t|
    t.integer  "artist_id"
    t.integer  "connected_artist_id"
    t.boolean  "is_approved",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feedback_topics", :force => true do |t|
    t.string   "name"
    t.string   "info"
    t.string   "emails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "feedback_topic_id",                    :null => false
    t.string   "user_type"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
    t.boolean  "is_read",           :default => false
  end

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type",                    :null => false
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type",                      :null => false
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "genre_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "genre_id"
    t.integer  "liking_count", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mentioned_posts", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.integer  "artist_id"
    t.integer  "status"
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

  create_table "newsfeeds", :force => true do |t|
    t.integer  "user_id"
    t.integer  "band_id"
    t.string   "newsitem_type"
    t.integer  "newsitem_id"
    t.string   "msg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              :default => ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                :default => false
    t.datetime "updated_at",                              :null => false
    t.datetime "created_at",                              :null => false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
  end

  add_index "notifications", ["conversation_id"], :name => "index_notifications_on_conversation_id"

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

  create_table "playlists", :force => true do |t|
    t.integer  "user_id"
    t.integer  "song_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "artist_id"
    t.string   "msg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",           :default => false
    t.string   "ancestry"
    t.boolean  "is_bulletin",          :default => false
    t.boolean  "is_read",              :default => false
    t.string   "mentioned_users"
    t.string   "mentioned_user_ids"
    t.string   "mentioned_artists"
    t.string   "mentioned_artist_ids"
    t.string   "postitem_type"
    t.integer  "postitem_id"
    t.boolean  "is_newsfeed",          :default => false
    t.integer  "reply_to_id"
  end

  add_index "posts", ["ancestry"], :name => "index_posts_on_ancestry"

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

  create_table "receipts", :force => true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                                  :null => false
    t.boolean  "read",                          :default => false
    t.boolean  "trashed",                       :default => false
    t.boolean  "deleted",                       :default => false
    t.string   "mailbox_type",    :limit => 25
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "receipts", ["notification_id"], :name => "index_receipts_on_notification_id"

  create_table "songs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "artist_music_id"
    t.text     "description"
    t.string   "song_file_name"
    t.string   "song_content_type"
    t.integer  "song_file_size"
    t.datetime "song_updated_at"
    t.integer  "total_played",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_processed",      :default => false
    t.string   "file_name"
    t.string   "title"
    t.string   "album_name"
    t.string   "artist_name"
    t.string   "genre"
    t.string   "track"
    t.date     "year"
    t.boolean  "is_featured",       :default => false
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
    t.string   "mention_name"
    t.text     "bio"
    t.string   "user_type"
    t.integer  "invitation_id"
    t.integer  "invitation_limit"
    t.string   "user_account_type"
    t.boolean  "notification_on",                 :default => true
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
  end

  add_index "users", ["activation_token"], :name => "index_users_on_activation_token"
  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_users_on_last_logout_at_and_last_activity_at"
  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type"], :name => "index_votes_on_votable_id_and_votable_type"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

  add_foreign_key "notifications", "conversations", :name => "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", :name => "receipts_on_notification_id"

end
