# frozen_string_literal: true

class AddIndexesToColsOfMessages < ActiveRecord::Migration[7.1]
  def change
    add_index :messages, %i[inbox_id created_at]
  end
end
