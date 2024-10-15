# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :prescription

  def failed?
    status == 'failed'
  end
end

# == Schema Information
#
# Table name: payments
#
#  id              :integer          not null, primary key
#  amount          :integer
#  payment_type    :string
#  status          :string
#  prescription_id :integer
#  user_id         :integer
#
# Indexes
#
#  index_payments_on_user_id  (user_id)
#
