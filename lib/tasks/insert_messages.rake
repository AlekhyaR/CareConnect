# frozen_string_literal: true

# lib/tasks/insert_messages.rake
namespace :messages do
  desc 'Insert 100,000 messages into the Message table'
  task insert: :environment do
    batch_size = 1000
    message_data = []
    doctor_inbox = Inbox.where(user_id: User.default_doctor.id).first
    patient_outbox = Outbox.where(user_id: User.current.id).first

    begin
      ActiveRecord::Base.transaction do
        100_000.times do |i|
          message_data << {
            outbox_id: patient_outbox.id,
            inbox_id: doctor_inbox.id,
            body: "Test message #{i + 200_002}",
            read: false,
            created_at: Time.current,
            updated_at: Time.current
          }

          # Insert in batches of 1000
          if message_data.size >= batch_size
            Message.insert_all!(message_data)
            message_data = [] # Clear the batch after inserting
          end
        end

        # Insert any remaining records
        Message.insert_all!(message_data) unless message_data.empty?

        inbox_unread_messages_count = Message.where(inbox_id: doctor_inbox.id, read: false).count
        doctor_inbox.update!(unread_messages_count: inbox_unread_messages_count)

        outbox_messages_count = Message.where(outbox_id: patient_outbox.id).count
        patient_outbox.update!(sent_messages_count: outbox_messages_count)
      end
      puts 'All records inserted successfully.'
    rescue StandardError => e
      puts "Error occurred: #{e.message}"
      raise ActiveRecord::Rollback
    end
  end
end
