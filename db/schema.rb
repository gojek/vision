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

ActiveRecord::Schema.define(version: 20190121041026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_request_approvals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "access_request_id"
    t.boolean  "approved"
    t.text     "notes"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "access_request_approvals", ["access_request_id"], name: "index_access_request_approvals_on_access_request_id", using: :btree
  add_index "access_request_approvals", ["user_id"], name: "index_access_request_approvals_on_user_id", using: :btree

  create_table "access_request_collaborators", force: :cascade do |t|
    t.integer "user_id"
    t.integer "access_request_id"
  end

  add_index "access_request_collaborators", ["access_request_id"], name: "index_access_request_collaborators_on_access_request_id", using: :btree
  add_index "access_request_collaborators", ["user_id"], name: "index_access_request_collaborators_on_user_id", using: :btree

  create_table "access_request_comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "access_request_id"
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "hide",              default: false
  end

  create_table "access_request_statuses", force: :cascade do |t|
    t.integer  "access_request_id"
    t.string   "status"
    t.text     "reason"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "access_request_statuses", ["access_request_id"], name: "index_access_request_statuses_on_access_request_id", using: :btree

  create_table "access_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "request_type"
    t.string   "access_type"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "employee_name"
    t.string   "employee_position"
    t.string   "employee_email_address"
    t.string   "employee_department"
    t.string   "employee_phone"
    t.boolean  "employee_access"
    t.boolean  "fingerprint_business_area"
    t.boolean  "fingerprint_business_operations"
    t.boolean  "fingerprint_it_operations"
    t.boolean  "fingerprint_server_room"
    t.boolean  "fingerprint_archive_room"
    t.boolean  "fingerprint_engineering_area"
    t.string   "corporate_email"
    t.boolean  "internet_access"
    t.boolean  "slack_access"
    t.boolean  "admin_tools"
    t.boolean  "vpn_access"
    t.boolean  "github_gitlab"
    t.boolean  "exit_interview"
    t.boolean  "access_card"
    t.boolean  "parking_cards"
    t.boolean  "id_card"
    t.boolean  "name_card"
    t.boolean  "insurance_card"
    t.boolean  "cash_advance"
    t.boolean  "password_reset"
    t.string   "user_identification"
    t.string   "asset_name"
    t.string   "aasm_state"
    t.datetime "request_date"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "business_justification"
    t.boolean  "metabase",                        default: false
    t.boolean  "solutions_dashboard",             default: false
  end

  add_index "access_requests", ["user_id"], name: "index_access_requests_on_user_id", using: :btree

  create_table "approvals", force: :cascade do |t|
    t.integer  "change_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
    t.boolean  "approve"
    t.text     "notes"
    t.datetime "approval_date"
  end

  add_index "approvals", ["change_request_id"], name: "index_approvals_on_change_request_id", using: :btree
  add_index "approvals", ["user_id"], name: "index_approvals_on_user_id", using: :btree

  create_table "cabs", force: :cascade do |t|
    t.datetime "meet_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "room"
    t.text     "notes"
    t.string   "participant"
    t.string   "event_id"
  end

  add_index "cabs", ["meet_date"], name: "index_cabs_on_meet_date", unique: true, using: :btree

  create_table "change_request_statuses", force: :cascade do |t|
    t.string   "status"
    t.text     "reason"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "change_request_id"
    t.boolean  "deploy_delayed"
  end

  add_index "change_request_statuses", ["change_request_id"], name: "index_change_request_statuses_on_change_request_id", using: :btree

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

  add_index "change_request_versions", ["item_type", "item_id"], name: "index_change_request_versions_on_item_type_and_item_id", using: :btree

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
    t.boolean  "testing_environment_available", default: true
    t.text     "testing_procedure"
    t.datetime "schedule_change_date"
    t.datetime "planned_completion"
    t.datetime "grace_period_starts"
    t.datetime "grace_period_end"
    t.text     "implementation_notes"
    t.text     "grace_period_notes"
    t.integer  "user_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
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
    t.integer  "reference_cr_id"
    t.string   "google_event_id"
    t.boolean  "downtime_expected"
    t.integer  "expected_downtime_in_minutes"
  end

  add_index "change_requests", ["cab_id"], name: "index_change_requests_on_cab_id", using: :btree
  add_index "change_requests", ["reference_cr_id"], name: "index_change_requests_on_reference_cr_id", using: :btree
  add_index "change_requests", ["user_id"], name: "index_change_requests_on_user_id", using: :btree

  create_table "change_requests_associated_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "change_request_id"
  end

  add_index "change_requests_associated_users", ["change_request_id"], name: "index_change_requests_associated_users_on_change_request_id", using: :btree
  add_index "change_requests_associated_users", ["user_id"], name: "index_change_requests_associated_users_on_user_id", using: :btree

  create_table "collaborators", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "change_request_id"
  end

  add_index "collaborators", ["change_request_id"], name: "index_collaborators_on_change_request_id", using: :btree
  add_index "collaborators", ["user_id"], name: "index_collaborators_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "change_request_id"
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "hide",              default: false
  end

  add_index "comments", ["change_request_id"], name: "index_comments_on_change_request_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "implementers", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "change_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
  end

  add_index "implementers", ["change_request_id"], name: "index_implementers_on_change_request_id", using: :btree
  add_index "implementers", ["user_id"], name: "index_implementers_on_user_id", using: :btree

  create_table "incident_report_collaborators", force: :cascade do |t|
    t.integer "user_id"
    t.integer "incident_report_id"
  end

  add_index "incident_report_collaborators", ["incident_report_id"], name: "index_incident_report_collaborators_on_incident_report_id", using: :btree
  add_index "incident_report_collaborators", ["user_id"], name: "index_incident_report_collaborators_on_user_id", using: :btree

  create_table "incident_report_logs", force: :cascade do |t|
    t.integer  "incident_report_id"
    t.integer  "user_id"
    t.text     "reason"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "incident_report_logs", ["incident_report_id"], name: "index_incident_report_logs_on_incident_report_id", using: :btree
  add_index "incident_report_logs", ["user_id"], name: "index_incident_report_logs_on_user_id", using: :btree

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

  add_index "incident_report_versions", ["item_type", "item_id"], name: "index_incident_report_versions_on_item_type_and_item_id", using: :btree

  create_table "incident_reports", force: :cascade do |t|
    t.string   "service_impact"
    t.text     "problem_details"
    t.string   "how_detected"
    t.datetime "occurrence_time"
    t.datetime "detection_time"
    t.datetime "acknowledge_time"
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
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.datetime "resolved_time"
    t.decimal  "resolution_duration"
    t.decimal  "recovery_duration"
    t.boolean  "expected",                     default: false
    t.boolean  "has_further_action",           default: false
    t.text     "action_item"
    t.string   "action_item_status"
    t.datetime "action_item_done_time"
    t.integer  "time_to_acknowledge_duration"
  end

  add_index "incident_reports", ["user_id"], name: "index_incident_reports_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "change_request_id"
    t.integer  "incident_report_id"
    t.boolean  "read"
    t.string   "message"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "access_request_id"
  end

  add_index "notifications", ["change_request_id"], name: "index_notifications_on_change_request_id", using: :btree
  add_index "notifications", ["incident_report_id"], name: "index_notifications_on_incident_report_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "read_marks", force: :cascade do |t|
    t.integer  "readable_id"
    t.string   "readable_type", null: false
    t.integer  "reader_id",     null: false
    t.datetime "timestamp"
    t.string   "reader_type"
  end

  add_index "read_marks", ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "testers", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "change_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
  end

  add_index "testers", ["change_request_id"], name: "index_testers_on_change_request_id", using: :btree
  add_index "testers", ["user_id"], name: "index_testers_on_user_id", using: :btree

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
    t.string   "slack_username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "access_request_approvals", "access_requests"
  add_foreign_key "access_request_approvals", "users"
  add_foreign_key "access_request_collaborators", "access_requests"
  add_foreign_key "access_request_collaborators", "users"
  add_foreign_key "access_request_statuses", "access_requests"
  add_foreign_key "access_requests", "users"
  add_foreign_key "approvals", "change_requests"
  add_foreign_key "approvals", "users"
  add_foreign_key "change_request_statuses", "change_requests"
  add_foreign_key "change_requests", "cabs"
  add_foreign_key "change_requests", "change_requests", column: "reference_cr_id"
  add_foreign_key "change_requests", "users"
  add_foreign_key "change_requests_associated_users", "change_requests"
  add_foreign_key "change_requests_associated_users", "users"
  add_foreign_key "comments", "change_requests"
  add_foreign_key "comments", "users"
  add_foreign_key "implementers", "change_requests"
  add_foreign_key "implementers", "users"
  add_foreign_key "incident_report_collaborators", "incident_reports"
  add_foreign_key "incident_report_collaborators", "users"
  add_foreign_key "incident_report_logs", "incident_reports"
  add_foreign_key "incident_report_logs", "users"
  add_foreign_key "incident_reports", "users"
  add_foreign_key "notifications", "change_requests"
  add_foreign_key "notifications", "incident_reports"
  add_foreign_key "notifications", "users"
  add_foreign_key "testers", "change_requests"
  add_foreign_key "testers", "users"
end
