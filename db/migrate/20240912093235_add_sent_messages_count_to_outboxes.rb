# frozen_string_literal: true

class AddSentMessagesCountToOutboxes < ActiveRecord::Migration[7.1]
  def change
    add_column :outboxes, :sent_messages_count, :integer, default: 0, null: false
  end
end
