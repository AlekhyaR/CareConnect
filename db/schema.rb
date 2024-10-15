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

ActiveRecord::Schema[7.1].define(version: 2024_09_13_113446) do
  create_table "inboxes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "unread_messages_count", default: 0
    t.index ["unread_messages_count"], name: "index_inboxes_on_unread_messages_count"
    t.index ["user_id"], name: "index_inboxes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.integer "outbox_id"
    t.integer "inbox_id"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_to_id"
    t.integer "prescription_id"
    t.boolean "replied", default: false
    t.integer "replied_to"
    t.index ["inbox_id", "created_at"], name: "index_messages_on_inbox_id_and_created_at"
    t.index ["inbox_id"], name: "index_messages_on_inbox_id"
    t.index ["outbox_id"], name: "index_messages_on_outbox_id"
    t.index ["prescription_id"], name: "index_messages_on_prescription_id"
  end

  create_table "outboxes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "sent_messages_count", default: 0, null: false
    t.index ["user_id"], name: "index_outboxes_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "amount"
    t.integer "prescription_id"
    t.string "payment_type"
    t.string "status"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "prescriptions", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "doctor_id", null: false
    t.datetime "issued_at"
    t.datetime "valid_until"
    t.text "medication"
    t.string "dosage"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["doctor_id"], name: "index_prescriptions_on_doctor_id"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "is_patient", default: true, null: false
    t.boolean "is_doctor", default: false, null: false
    t.boolean "is_admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  add_foreign_key "messages", "prescriptions"
  add_foreign_key "prescriptions", "users", column: "doctor_id"
  add_foreign_key "prescriptions", "users", column: "patient_id"
end
