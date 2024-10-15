# frozen_string_literal: true

class CreateUsersMessagesInboxesOutboxesAndPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.boolean :is_patient, default: true, null: false
      t.boolean :is_doctor, default: false, null: false
      t.boolean :is_admin, default: false, null: false
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :messages do |t|
      t.text :body
      t.references :outbox
      t.references :inbox
      t.boolean :read, default: false, null: false
      t.timestamps
    end

    create_table :inboxes do |t|
      t.references :user
    end

    create_table :outboxes do |t|
      t.references :user
    end

    create_table :payments do |t|
      t.references :user
    end
  end
end
