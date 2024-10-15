# frozen_string_literal: true

class AddRepliedColsToMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :replied, :boolean, default: false
    add_column :messages, :replied_to, :integer
  end
end
