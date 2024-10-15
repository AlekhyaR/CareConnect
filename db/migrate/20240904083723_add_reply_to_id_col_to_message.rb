# frozen_string_literal: true

class AddReplyToIdColToMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :reply_to_id, :integer
  end
end
