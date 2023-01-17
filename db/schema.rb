# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_01_17_084454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "critic_movies", force: :cascade do |t|
    t.bigint "critic_id"
    t.bigint "movie_id", null: false
    t.integer "score"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "critic_first_name"
    t.string "critic_last_name"
    t.string "publication"
    t.index ["critic_id"], name: "index_critic_movies_on_critic_id"
    t.index ["movie_id"], name: "index_critic_movies_on_movie_id"
  end

  create_table "critics", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "critic_uri"
    t.string "publication_uri"
    t.string "publication"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.date "release_date"
    t.string "genre"
    t.integer "metacritic_score"
    t.integer "rotten_tomatoes_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "movie_uri"
    t.string "image_uri"
    t.index ["movie_uri"], name: "index_movies_on_movie_uri", unique: true
  end

end
