# frozen_string_literal: true

class Message < ApplicationRecord
  # Associations
  belongs_to :inbox
  belongs_to :outbox
  belongs_to :prescription, optional: true
  belongs_to :replied_with_message, class_name: 'Message', foreign_key: 'replied_to', optional: true
  belongs_to :replied_for, class_name: 'Message', foreign_key: 'reply_to_id', optional: true

  # Validations
  validates :body, presence: true, length: { maximum: 500 }

  after_create :update_inbox_and_outbox_count
  after_update :update_unread_count_on_read
  after_destroy :decrement_unread_count_if_necessary

  scope :unread, -> { where(read: false) }

  class << self
    def notify_admin_of_prescription_request(user, admin, body, prescription_id)
      message = new( # Create a Message object here
        body:,
        outbox: user.outbox,
        inbox: admin.inbox,
        prescription_id:
      )
      create_with_transaction(message)
    end

    def create_message(params)
      create_with_transaction(new(params))
    end

    def create_reply(params)
      message = prepare_reply_params(params)

      create_with_transaction(message) do |saved_message|
        update_replied_message(saved_message.reply_to_id, saved_message.id)
      end
    end

    def determine_recipient_inbox(reply_message_id)
      return User.default_doctor.inbox unless reply_message_id

      old_message = find_by(id: reply_message_id)
      return old_message.inbox unless old_message.inbox.user.is_patient?

      old_message.created_at > 7.days.ago ? User.default_doctor.inbox : User.default_admin.inbox
    end

    private

    def prepare_reply_params(params)
      params_with_indifferent_access = params.to_h.with_indifferent_access
      reply_to_id = params_with_indifferent_access[:reply_to_id]
      new({
        outbox: User.current.outbox,
        inbox: determine_recipient_inbox(reply_to_id),
        reply_to_id:
      }.merge(params))
    end

    def create_with_transaction(message)
      ActiveRecord::Base.transaction do
        message.save!
        yield(message) if block_given?
        message
      end
    rescue ActiveRecord::RecordInvalid => e
      message.errors.add(:base, "Error saving message: #{e.record.errors.full_messages.join(', ')}")
      message
    end

    def update_replied_message(reply_to_id, new_message_id)
      where(id: reply_to_id).update(replied: true, replied_to: new_message_id) if reply_to_id
    end
  end

  def mark_as_read
    update(read: true) unless read?
  end

  def unread?
    !read
  end

  private

  def update_inbox_and_outbox_count
    inbox.increment!(:unread_messages_count)
    outbox.increment!(:sent_messages_count)
  end

  def update_unread_count_on_read
    decrement_unread_messages_count if read?
  end

  def decrement_unread_messages_count
    inbox.decrement!(:unread_messages_count)
  end

  def decrement_unread_count_if_necessary
    decrement_unread_messages_count if unread?
  end
end

# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  body            :text
#  read            :boolean          default(FALSE), not null
#  replied         :boolean          default(FALSE)
#  replied_to      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  inbox_id        :integer
#  outbox_id       :integer
#  prescription_id :integer
#  reply_to_id     :integer
#
# Indexes
#
#  index_messages_on_inbox_id                 (inbox_id)
#  index_messages_on_inbox_id_and_created_at  (inbox_id,created_at)
#  index_messages_on_outbox_id                (outbox_id)
#  index_messages_on_prescription_id          (prescription_id)
#
# Foreign Keys
#
#  prescription_id  (prescription_id => prescriptions.id)
#
