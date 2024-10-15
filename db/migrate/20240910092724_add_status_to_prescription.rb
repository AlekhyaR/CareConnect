# frozen_string_literal: true

class AddStatusToPrescription < ActiveRecord::Migration[7.1]
  def change
    add_column :prescriptions, :status, :string
  end
end
