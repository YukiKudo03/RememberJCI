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

ActiveRecord::Schema[8.0].define(version: 2026_02_03_231102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "badge_type", null: false
    t.datetime "awarded_at", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "badge_type"], name: "index_achievements_on_user_id_and_badge_type", unique: true
    t.index ["user_id"], name: "index_achievements_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "text_id"
    t.bigint "user_id"
    t.bigint "assigned_by_id", null: false
    t.datetime "deadline"
    t.index ["assigned_by_id"], name: "index_assignments_on_assigned_by_id"
    t.index ["group_id"], name: "index_assignments_on_group_id"
    t.index ["text_id"], name: "index_assignments_on_text_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.bigint "created_by_id", null: false
    t.index ["created_by_id"], name: "index_groups_on_created_by_id"
    t.index ["name"], name: "index_groups_on_name"
  end

  create_table "learning_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "text_id"
    t.integer "current_level", default: 0
    t.integer "best_score", default: 0
    t.integer "total_attempts", default: 0
    t.integer "total_study_time", default: 0
    t.index ["text_id"], name: "index_learning_progresses_on_text_id"
    t.index ["user_id", "text_id"], name: "index_learning_progresses_on_user_id_and_text_id", unique: true
    t.index ["user_id"], name: "index_learning_progresses_on_user_id"
  end

  create_table "test_submissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "test_id", null: false
    t.text "submitted_text"
    t.integer "auto_score"
    t.integer "manual_score"
    t.integer "status", default: 0
    t.string "audio_file_path"
    t.text "feedback"
    t.index ["test_id", "user_id"], name: "index_test_submissions_on_test_id_and_user_id", unique: true
    t.index ["test_id"], name: "index_test_submissions_on_test_id"
    t.index ["user_id"], name: "index_test_submissions_on_user_id"
  end

  create_table "tests", force: :cascade do |t|
    t.bigint "text_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "test_type"
    t.integer "time_limit"
    t.datetime "available_from"
    t.datetime "available_until"
    t.bigint "created_by_id", null: false
    t.index ["created_by_id"], name: "index_tests_on_created_by_id"
    t.index ["text_id"], name: "index_tests_on_text_id"
  end

  create_table "texts", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.string "category"
    t.integer "difficulty", default: 1, null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_texts_on_category"
    t.index ["created_by_id"], name: "index_texts_on_created_by_id"
    t.index ["difficulty"], name: "index_texts_on_difficulty"
    t.index ["title"], name: "index_texts_on_title"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "achievements", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "groups"
  add_foreign_key "assignments", "texts"
  add_foreign_key "assignments", "users"
  add_foreign_key "assignments", "users", column: "assigned_by_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "users", column: "created_by_id"
  add_foreign_key "learning_progresses", "texts"
  add_foreign_key "learning_progresses", "users"
  add_foreign_key "test_submissions", "tests"
  add_foreign_key "test_submissions", "users"
  add_foreign_key "tests", "texts"
  add_foreign_key "tests", "users", column: "created_by_id"
  add_foreign_key "texts", "users", column: "created_by_id"
end
