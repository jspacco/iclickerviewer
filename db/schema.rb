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

ActiveRecord::Schema.define(version: 2018_07_13_193227) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "class_period_caches", force: :cascade do |t|
    t.integer "num_questions"
    t.float "avg_secs_question"
    t.integer "num_questions_updated"
    t.integer "total_class_periods"
    t.string "session_code"
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_class_period_caches_on_course_id"
  end

  create_table "class_periods", force: :cascade do |t|
    t.string "session_code"
    t.string "name"
    t.string "participation"
    t.string "performance"
    t.string "min_response"
    t.string "min_response_string"
    t.datetime "date"
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_class_periods_on_course_id"
  end

  create_table "course_caches", force: :cascade do |t|
    t.float "avg_questions_class"
    t.float "avg_secs_question"
    t.integer "num_classes_updated"
    t.integer "total_classes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "course_hashes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course_hash"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "term"
    t.integer "year"
    t.string "institution"
    t.string "instructor"
    t.string "folder_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matching_questions", force: :cascade do |t|
    t.integer "question_id"
    t.integer "matching_question_id"
    t.integer "is_match"
    t.integer "match_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "matching_question_id"], name: "matching_question_index", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.string "name"
    t.string "start"
    t.string "stop"
    t.integer "num_seconds"
    t.integer "question_index"
    t.integer "response_a"
    t.integer "response_b"
    t.integer "response_c"
    t.integer "response_d"
    t.integer "response_e"
    t.integer "correct_a"
    t.integer "correct_b"
    t.integer "correct_c"
    t.integer "correct_d"
    t.integer "correct_e"
    t.string "is_deleted"
    t.integer "question_type"
    t.integer "question_pair"
    t.bigint "class_period_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_period_id"], name: "index_questions_on_class_period_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.text "image"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.string "clicker_id"
    t.float "first_answer_time"
    t.float "total_time"
    t.integer "num_attempts"
    t.string "loaned_clicker_to"
    t.string "first_response"
    t.string "response"
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_votes_on_question_id"
  end

  add_foreign_key "class_period_caches", "courses"
  add_foreign_key "class_periods", "courses"
  add_foreign_key "questions", "class_periods"
  add_foreign_key "votes", "questions"
end
