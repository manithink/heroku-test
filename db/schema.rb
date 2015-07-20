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

ActiveRecord::Schema.define(version: 20140820055230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "admin_settings", force: true do |t|
    t.text    "about_us"
    t.text    "contact_us"
    t.string  "youtube_url"
    t.string  "image_ids",             default: [], array: true
    t.integer "care_giver_company_id"
    t.string  "custom_url"
  end

  create_table "assigned_events", force: true do |t|
    t.integer  "event_id"
    t.integer  "care_client_id"
    t.integer  "care_giver_id"
    t.integer  "cc_event_id"
    t.integer  "pcg_event_id"
    t.datetime "checked_in_at"
    t.datetime "checked_out_at"
    t.json     "service_record_json"
    t.string   "status"
    t.string   "signature_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "signature"
    t.integer  "distance_travelled",   default: 0
    t.float    "time_travelled"
    t.float    "latitude_checkin"
    t.float    "longitude_checkin"
    t.float    "latitude_checkout"
    t.float    "longitude_checkout"
    t.json     "alertreminderjob_ids"
  end

  create_table "care_clients", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.date     "dob"
    t.string   "telephone"
    t.string   "password"
    t.string   "mobile_no"
    t.string   "time_zone"
    t.integer  "country_id"
    t.string   "address_1"
    t.string   "address_2"
    t.integer  "state_id"
    t.string   "city"
    t.string   "zip"
    t.string   "telephony_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "care_giver_company_id"
    t.integer  "user_id"
    t.string   "status",                default: "Deactive"
    t.string   "name"
    t.string   "account_type"
    t.string   "medical_record_number"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "care_clients_givers", force: true do |t|
    t.integer "care_giver_id"
    t.integer "care_client_id"
  end

  create_table "care_clients_services", force: true do |t|
    t.integer  "care_client_id"
    t.integer  "service_id"
    t.string   "option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "care_giver_company_id"
  end

  create_table "care_giver_companies", force: true do |t|
    t.string   "company_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "pcgc_state"
    t.string   "pcgc_country"
    t.string   "zip"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.integer  "year_founded"
    t.integer  "organistaion_type_id"
    t.string   "admin_first_name"
    t.string   "admin_last_name"
    t.string   "admin_email"
    t.string   "admin_time_zone"
    t.string   "alt_first_name"
    t.string   "alt_last_name"
    t.string   "alt_email"
    t.string   "alt_phone"
    t.string   "status",                 default: "Deactive"
    t.string   "subscription_state"
    t.string   "subscription_address_1"
    t.string   "subscription_address_2"
    t.string   "subscription_city"
    t.integer  "subscription_type_id"
    t.integer  "package_type_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_phone"
    t.string   "subscription_zip"
    t.string   "subscription_country"
    t.integer  "company_type_id"
    t.boolean  "checked"
    t.boolean  "is_admin_company",       default: false
    t.integer  "admin_setting_id"
    t.boolean  "is_private_record",      default: false
  end

  create_table "care_givers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "zip"
    t.string   "alternative_no"
    t.string   "mobile_no"
    t.string   "gender"
    t.date     "dob"
    t.string   "telephony_id"
    t.string   "highest_education"
    t.string   "college_name"
    t.text     "certificates"
    t.text     "training"
    t.date     "active_since"
    t.string   "emergency_first_name"
    t.string   "emergency_last_name"
    t.string   "emergency_phone_no1"
    t.string   "emergency_phone_no2"
    t.text     "emergency_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "state_id"
    t.integer  "school_year_graduated"
    t.string   "status",                default: "Deactive"
    t.integer  "care_giver_company_id"
    t.integer  "year_graduated"
    t.string   "name"
  end

  create_table "care_plan_settings", force: true do |t|
    t.boolean  "farcare_tracker_used"
    t.boolean  "detect_late_checkout"
    t.string   "end_of_week"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "care_giver_company_id"
    t.hstore   "alerts"
    t.hstore   "telephony"
  end

  create_table "check_inout_alerts", force: true do |t|
    t.boolean  "confirmed_and_actual_notification"
    t.boolean  "confirmed_and_actual_warning"
    t.boolean  "confirmed_and_actual_alert"
    t.boolean  "checkin_and_checkout_notification"
    t.boolean  "checkin_and_checkout_warning"
    t.boolean  "checkin_and_checkout_alert"
    t.boolean  "send_email"
    t.boolean  "send_sms"
    t.string   "email"
    t.string   "sms"
    t.integer  "care_giver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "signature"
  end

  create_table "company_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_series", force: true do |t|
    t.integer  "frequency",  default: 1
    t.string   "period",     default: "monthly"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "upto"
  end

  create_table "events", force: true do |t|
    t.string   "title"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",         default: false
    t.text     "description"
    t.integer  "event_series_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",          default: "available"
    t.boolean  "on_vacation",     default: false
    t.boolean  "is_split_up",     default: false
  end

  add_index "events", ["event_series_id"], name: "index_events_on_event_series_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisation_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "package_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "service_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "care_giver_company_id"
  end

  create_table "service_trackers", force: true do |t|
    t.integer  "care_client_id"
    t.integer  "care_giver_id"
    t.json     "service_record_json"
    t.datetime "checkout_time"
    t.datetime "submit_time"
    t.string   "status"
    t.string   "signature_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.string   "name"
    t.integer  "service_category_id"
    t.integer  "care_giver_company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_zones", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "approved",               default: false, null: false
    t.string   "unique_session_id"
  end

  add_index "users", ["approved"], name: "index_users_on_approved", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "vacation_managements", force: true do |t|
    t.text     "reason"
    t.integer  "care_giver_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "startdate"
    t.datetime "enddate"
    t.boolean  "all_day"
    t.string   "comments"
  end

end
