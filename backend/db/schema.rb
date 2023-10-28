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

ActiveRecord::Schema[7.0].define(version: 2023_08_30_075521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.float "balance"
    t.boolean "owed", default: false
    t.boolean "creditcard", default: false
    t.date "opening_date"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.string "ctype"
    t.float "outstanding_bill", default: 0.0
    t.date "last_paid"
    t.bigint "account_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_cards_on_account_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "daily_logs", force: :cascade do |t|
    t.float "opening_balance"
    t.float "closing_balance"
    t.date "date"
    t.integer "total_transactions"
    t.json "meta"
    t.bigint "account_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_daily_logs_on_account_id"
    t.index ["user_id"], name: "index_daily_logs_on_user_id"
  end

  create_table "mops", force: :cascade do |t|
    t.string "name", null: false
    t.json "meta", default: {}
    t.bigint "account_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_mops_on_account_id"
    t.index ["user_id"], name: "index_mops_on_user_id"
  end

  create_table "sub_categories", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "category_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_sub_categories_on_category_id"
    t.index ["user_id"], name: "index_sub_categories_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.float "amount"
    t.string "ttype"
    t.date "date"
    t.integer "party"
    t.integer "category_id"
    t.boolean "pseudo", default: false
    t.float "balance_before"
    t.float "balance_after"
    t.json "meta", default: {}
    t.string "comments"
    t.integer "sub_category_id"
    t.bigint "mop_id"
    t.bigint "account_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["mop_id"], name: "index_transactions_on_mop_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "password", default: ""
    t.string "theme", default: "dark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.json "meta", default: {}
    t.string "image_url", default: "empty_user.jpg"
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
