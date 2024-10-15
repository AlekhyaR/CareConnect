# frozen_string_literal: true

class AddAmountToPayment < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :amount, :integer
    add_column :payments, :prescription_id, :integer
    add_column :payments, :payment_type, :string
    add_column :payments, :status, :string
  end
end
