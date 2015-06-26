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

ActiveRecord::Schema.define(version: 20150625070012) do

  create_table "incident_report_versions", force: :cascade do |t|
    t.string   "item_type",       null: false
    t.integer  "item_id",         null: false
    t.string   "event",           null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.string   "author_username"
    t.integer  "word_count"
    t.text     "object_changes"
  end

  add_index "incident_report_versions", ["item_type", "item_id"], name: "index_incident_report_versions_on_item_type_and_item_id"

  create_table "incident_reports", force: :cascade do |t|
    t.string   "service_impact"
    t.text     "problem_details"
    t.string   "how_detected"
    t.datetime "occurrence_time"
    t.datetime "detection_time"
    t.datetime "recovery_time"
    t.string   "source"
    t.integer  "rank"
    t.string   "loss_related"
    t.text     "occurred_reason"
    t.text     "overlooked_reason"
    t.text     "recovery_action"
    t.text     "prevent_action"
    t.string   "recurrence_concern"
    t.string   "current_status"
    t.string   "measurer_status"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "incident_reports", ["user_id"], name: "index_incident_reports_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",              default: "", null: false
    t.integer  "sign_in_count",      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "role"
    t.integer  "failed_attempts",    default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.string   "uid"
    t.string   "provider"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
