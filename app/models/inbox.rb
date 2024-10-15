# frozen_string_literal: true

class Inbox < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :nullify

  after_initialize :set_default_values

  private

  def set_default_values
    self.unread_messages_count ||= 0
  end
end

# == Schema Information
#
# Table name: inboxes
#
#  id                    :integer          not null, primary key
#  unread_messages_count :integer          default(0)
#  user_id               :integer
#
# Indexes
#
#  index_inboxes_on_unread_messages_count  (unread_messages_count)
#  index_inboxes_on_user_id                (user_id)
#
