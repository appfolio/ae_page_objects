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

ActiveRecord::Schema.define(version: 20141012023819) do

  create_table "authors", force: true do |t|
    t.integer  "lock_version"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "books", force: true do |t|
    t.integer  "lock_version"
    t.integer  "author_id"
    t.string   "title"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "forum_posts", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "indices", force: true do |t|
    t.integer "lock_version"
    t.integer "pages"
    t.integer "book_id"
  end

end
