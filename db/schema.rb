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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20120512222955) do


  create_table "spots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "text"
  end

  create_table "comments", force: true do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.string   "content"
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "external_auth_providers", force: true do |t|
    t.string  "provider_type", null: false
    t.string  "provider_id",   null: false
    t.integer "user_id",       null: false
  end

  add_index "external_auth_providers", ["user_id"], name: "index_external_auth_providers_on_user_id"

  create_table "pages", force: true do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "content"
  end

  add_index "pages", ["title"], name: "index_pages_on_title"

  create_table "ratings", force: true do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "value"
    t.string   "rating_text"
  end

  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id"

  create_table "relationships", force: true do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.string   "target_type"
    t.integer  "target_id"
  end

  add_index "relationships", ["user_id"], name: "index_relationships_on_user_id"


  create_table "tokens", force: true do |t|
    t.string  "hashed_access_token",  null: false
    t.string  "hashed_refresh_token"
    t.datetime    "expires_on"
    t.datetime    "refresh_by"
    t.integer "user_id",              null: false
    t.string  "provider"
    t.datetime "created_at",  null: false
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",              default: false
    t.boolean  "activated",          default: false
    t.boolean  "recover_password",   default: false
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
