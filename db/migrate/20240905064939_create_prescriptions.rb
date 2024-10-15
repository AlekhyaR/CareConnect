# frozen_string_literal: true

class CreatePrescriptions < ActiveRecord::Migration[7.1]
  def change
    create_table 'prescriptions', force: :cascade do |t|
      t.integer 'patient_id', null: false
      t.integer 'doctor_id', null: false
      t.datetime 'issued_at'
      t.datetime 'valid_until'
      t.text 'medication'
      t.string 'dosage'
      t.text 'notes'

      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.index ['doctor_id'], name: 'index_prescriptions_on_doctor_id'
      t.index ['patient_id'], name: 'index_prescriptions_on_patient_id'
    end

    add_foreign_key 'prescriptions', 'users', column: 'patient_id'
    add_foreign_key 'prescriptions', 'users', column: 'doctor_id'
  end
end
