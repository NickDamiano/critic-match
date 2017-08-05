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

ActiveRecord::Schema.define(version: 20170805052822) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "critic_movies", force: :cascade do |t|
    t.bigint "critics_id"
    t.bigint "movies_id"
    t.integer "score"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["critics_id"], name: "index_critic_movies_on_critics_id"
    t.index ["movies_id"], name: "index_critic_movies_on_movies_id"
  end

  create_table "critics", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "publications", default: [], array: true
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.date "release_date"
    t.string "genre"
    t.integer "metacritic_score"
    t.integer "rotten_tomatoes_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
