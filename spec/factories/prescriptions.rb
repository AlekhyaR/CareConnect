# frozen_string_literal: true

FactoryBot.define do
  factory :prescription do
    association :patient, factory: :user
    association :doctor, factory: :user
    issued_at { DateTime.now }
    valid_until { DateTime.now + 6.days }
    medication { 'Its medication' }
    dosage { 'Its dosage' }
  end

  factory :payment_record do
    association :prescription
    user_id { 1 }
    amount { 10 }
  end
end
# == Schema Information
#
# Table name: prescriptions
#
#  id          :integer          not null, primary key
#  dosage      :string
#  issued_at   :datetime
#  medication  :text
#  notes       :text
#  status      :string
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  doctor_id   :integer          not null
#  patient_id  :integer          not null
#
# Indexes
#
#  index_prescriptions_on_doctor_id   (doctor_id)
#  index_prescriptions_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  doctor_id   (doctor_id => users.id)
#  patient_id  (patient_id => users.id)
#
