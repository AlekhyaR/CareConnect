# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :patient, class_name: 'User'
  belongs_to :doctor, class_name: 'User'

  has_many :payments, dependent: :nullify

  validates :doctor, :patient, :medication, :dosage, :valid_until, presence: true

  validate :valid_until_date_cannot_be_in_the_past

  def active?
    valid_until >= Date.current && status.nil?
  end

  private

  def valid_until_date_cannot_be_in_the_past
    errors.add(:valid_until, "can't be in the past") if valid_until.present? && valid_until < Date.current
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
