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

ActiveRecord::Schema.define(version: 20160616050438) do

  create_table "approvers", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "change_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
    t.boolean  "approve"
    t.text     "reject_reason"
    t.datetime "approval_date"
  end

  add_index "approvers", ["change_request_id"], name: "index_approvers_on_change_request_id"
  add_index "approvers", ["user_id"], name: "index_approvers_on_user_id"

  create_table "cabs", force: :cascade do |t|
    t.datetime "meet_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "room"
    t.text     "notes"
    t.string   "participant"
    t.string   "event_id"
  end

  add_index "cabs", ["meet_date"], name: "index_cabs_on_meet_date", unique: true

  create_table "change_request_statuses", force: :cascade do |t|
    t.string   "status"
    t.text     "reason"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "change_request_id"
  end

  add_index "change_request_statuses", ["change_request_id"], name: "index_change_request_statuses_on_change_request_id"

  create_table "change_request_versions", force: :cascade do |t|
    t.string   "item_type",       null: false
    t.integer  "item_id",         null: false
    t.string   "event",           null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.string   "author_username"
    t.text     "object_changes"
  end

  add_index "change_request_versions", ["item_type", "item_id"], name: "index_change_request_versions_on_item_type_and_item_id"

  create_table "change_requests", force: :cascade do |t|
    t.string   "change_summary"
    t.string   "priority"
    t.text     "change_requirement"
    t.text     "business_justification"
    t.string   "requestor_position"
    t.text     "note"
    t.text     "analysis"
    t.text     "solution"
    t.text     "impact"
    t.string   "scope"
    t.text     "design"
    t.text     "backup"
    t.boolean  "testing_environment_available"
    t.text     "testing_procedure"
    t.text     "testing_notes"
    t.datetime "schedule_change_date"
    t.datetime "planned_completion"
    t.datetime "grace_period_starts"
    t.datetime "grace_period_end"
    t.text     "implementation_notes"
    t.text     "grace_period_notes"
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "net"
    t.text     "db"
    t.text     "os"
    t.string   "requestor_name"
    t.string   "status"
    t.text     "rollback_note"
    t.text     "reject_note"
    t.text     "close_note"
    t.text     "cancel_note"
    t.string   "state"
    t.string   "aasm_state"
    t.integer  "cab_id"
    t.text     "definition_of_success"
    t.text     "definition_of_failed"
    t.boolean  "category_application"
    t.boolean  "category_network_equipment"
    t.boolean  "category_server"
    t.boolean  "category_user_access"
    t.string   "category_other"
    t.boolean  "type_security_update"
    t.boolean  "type_install_uninstall"
    t.boolean  "type_configuration_change"
    t.boolean  "type_emergency_change"
    t.string   "type_other"
    t.text     "other_dependency"
    t.datetime "closed_date"
  end

  add_index "change_requests", ["cab_id"], name: "index_change_requests_on_cab_id"
  add_index "change_requests", ["user_id"], name: "index_change_requests_on_user_id"

  create_table "change_requests_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "change_request_id"
  end

  add_index "change_requests_users", ["change_request_id"], name: "index_change_requests_users_on_change_request_id"
  add_index "change_requests_users", ["user_id"], name: "index_change_requests_users_on_user_id"

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "change_request_id"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "comments", ["change_request_id"], name: "index_comments_on_change_request_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "implementers", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "change_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "implementers", ["change_request_id"], name: "index_implementers_on_change_request_id"

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
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "resolved_time"
    t.decimal  "resolution_duration"
    t.decimal  "recovery_duration"
  end

  add_index "incident_reports", ["user_id"], name: "index_incident_reports_on_user_id"

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "change_request_id"
    t.integer  "incident_report_id"
    t.boolean  "read"
    t.string   "message"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "notifications", ["change_request_id"], name: "index_notifications_on_change_request_id"
  add_index "notifications", ["incident_report_id"], name: "index_notifications_on_incident_report_id"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "read_marks", force: :cascade do |t|
    t.integer  "readable_id"
    t.string   "readable_type", null: false
    t.integer  "reader_id",     null: false
    t.datetime "timestamp"
    t.string   "reader_type"
  end

  add_index "read_marks", ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index"

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "testers", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "change_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "testers", ["change_request_id"], name: "index_testers_on_change_request_id"

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
    t.boolean  "is_admin"
    t.string   "position"
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "expired_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
