# frozen_string_literal: true

class AddPrescriptionIdToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :prescription, null: true, foreign_key: true
  end
end
