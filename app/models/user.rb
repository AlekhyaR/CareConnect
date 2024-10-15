# frozen_string_literal: true

class User < ApplicationRecord
  has_one :inbox, dependent: :destroy
  has_one :outbox, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :sent_messages, through: :outbox, source: :messages
  has_many :received_messages, through: :inbox, source: :messages

  scope :patient, -> { where(is_patient: true) }
  scope :admin, -> { where(is_admin: true) }
  scope :doctor, -> { where(is_doctor: true) }

  attr_accessor :default_admin

  def self.current
    User.patient.first
  end

  def self.default_admin
    @default_admin ||= User.admin.first
  end

  def self.default_doctor
    User.doctor.first
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def sender_name
    "#{full_name} #{role_suffix}"
  end

  alias recipient_name sender_name

  private

  def role_suffix
    if is_patient
      '(Patient)'
    elsif is_admin
      '(Admin)'
    else
      '(Doctor)'
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  first_name :string
#  is_admin   :boolean          default(FALSE), not null
#  is_doctor  :boolean          default(FALSE), not null
#  is_patient :boolean          default(TRUE), not null
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
