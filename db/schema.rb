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

ActiveRecord::Schema.define(version: 20150625031742) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "distros", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.string   "version"
    t.integer  "repo_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "architecture"
    t.text     "description"
  end

  add_index "packages", ["repo_id"], name: "index_packages_on_repo_id"

  create_table "repos", force: :cascade do |t|
    t.string   "name"
    t.integer  "distro_id"
    t.string   "url"
    t.string   "type"
    t.float    "fetch_last_version"
    t.datetime "fetch_last_date"
    t.datetime "last_fetch"
    t.boolean  "is_fetching",        default: false
    t.text     "fetch_log"
    t.boolean  "is_fetch_queued"
    t.text     "fetch_info"
  end

  add_index "repos", ["distro_id"], name: "index_repos_on_distro_id"

  create_table "softwares", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.string   "license"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
