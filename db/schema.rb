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

ActiveRecord::Schema[7.1].define(version: 2024_12_22_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "share_link_id", null: false
    t.string "email", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["share_link_id", "email"], name: "index_access_requests_on_share_link_id_and_email"
    t.index ["share_link_id"], name: "index_access_requests_on_share_link_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "filename", null: false
    t.string "content_type", null: false
    t.bigint "file_size", null: false
    t.string "storage_key", null: false
    t.text "ai_summary"
    t.string "ai_title"
    t.jsonb "ai_metadata", default: {}
    t.string "owner_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_token"], name: "index_documents_on_owner_token"
    t.index ["storage_key"], name: "index_documents_on_storage_key", unique: true
  end

  create_table "share_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "document_id", null: false
    t.string "token", null: false
    t.string "name"
    t.boolean "require_email", default: false
    t.boolean "allow_download", default: true
    t.datetime "expires_at"
    t.string "passcode_digest"
    t.integer "view_count", default: 0
    t.integer "download_count", default: 0
    t.datetime "last_viewed_at"
    t.jsonb "access_log", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "allowed_countries", default: [], array: true
    t.string "blocked_countries", default: [], array: true
    t.integer "max_views"
    t.integer "max_downloads"
    t.index ["document_id"], name: "index_share_links_on_document_id"
    t.index ["expires_at"], name: "index_share_links_on_expires_at"
    t.index ["token"], name: "index_share_links_on_token", unique: true
  end

  add_foreign_key "access_requests", "share_links"
  add_foreign_key "share_links", "documents"
end
