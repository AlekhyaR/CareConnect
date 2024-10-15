# frozen_string_literal: true

class Outbox < ApplicationRecord
  belongs_to :user
  has_many :messages, as: :outbox, dependent: :destroy
end

# == Schema Information
#
# Table name: outboxes
#
#  id                  :integer          not null, primary key
#  sent_messages_count :integer          default(0), not null
#  user_id             :integer
#
# Indexes
#
#  index_outboxes_on_user_id  (user_id)
#
