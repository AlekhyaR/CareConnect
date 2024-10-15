# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'Message creation and status' do
    let(:sender) { create(:user, :patient) }
    let(:recipient) { create(:user, :doctor) }
    let(:sender_outbox) { create(:outbox, user: sender) }
    let(:recipient_inbox) { create(:inbox, user: recipient) }

    context 'when a message is created' do
      it 'has an unread status by default' do
        message = described_class.create(body: 'Test message', outbox: sender_outbox, inbox: recipient_inbox)
        expect(message.read).to be_falsey
        expect(message).to be_unread
      end

      it 'is sent to the correct inbox and outbox' do
        message = described_class.create(body: 'Test message', outbox: sender_outbox, inbox: recipient_inbox)
        expect(sender.outbox.user_id).to eq(message.outbox.user_id)
        expect(recipient.inbox.user_id).to eq(message.inbox.user_id)
      end
    end

    context 'when a patient sends a message' do
      let(:patient) { create(:user, :patient) }
      let(:doctor) { create(:user, :doctor) }
      let(:patient_outbox) { create(:outbox, user: patient) }
      let(:doctor_inbox) { create(:inbox, user: doctor) }

      it 'appears in the patient’s outbox and the doctor’s inbox' do
        message = described_class.create_message(body: 'Test message', outbox: patient_outbox, inbox: doctor_inbox)
        expect(patient.outbox.user_id).to eq(message.outbox.user_id)
        expect(doctor.inbox.user_id).to eq(message.inbox.user_id)
      end
    end
  end

  describe 'message routing to admin inbox' do
    context 'when a patient replies to a message' do
      let(:patient) { create(:user, :patient) }
      let(:doctor) { create(:user, :doctor) }
      let(:default_admin) { create(:user, :admin) }
      let(:patient_inbox) { create(:inbox, user: patient) }
      let(:patient_outbox) { create(:outbox, user: patient) }
      let(:doctor_outbox) { create(:outbox, user: doctor) }

      before do
        allow(User).to receive(:default_admin).and_return(default_admin)
        create(:inbox, user: default_admin)
      end

      it 'moves to the admin’s inbox if the message is older than a week' do
        old_message = described_class.create(body: 'Old message', outbox: doctor_outbox, inbox: patient_inbox,
                                             created_at: 3.weeks.ago)
        reply_message = described_class.create_reply(body: 'Reply message', reply_to_id: old_message.id)
        old_message.reload

        expect(reply_message.inbox).to eq(default_admin.inbox)
        expect(default_admin.inbox.messages).to include(reply_message)
        expect(doctor.inbox.messages).not_to include(reply_message)
        expect(reply_message.reply_to_id).to eq(old_message.id)
        expect(old_message.replied_to).to eq(reply_message.id)
      end
    end
  end

  describe '#update_inbox_and_outbox_count' do
    let(:doctor) { create(:user, :doctor) }
    let(:patient) { create(:user, :patient) }
    let(:doctor_inbox) { create(:inbox, user: doctor, unread_messages_count: 0) }
    let(:patient_outbox) { create(:outbox, user: patient, sent_messages_count: 0) }

    it 'increments unread messages count in doctor’s inbox when a new message is created' do
      create(:message, outbox: patient_outbox, inbox: doctor_inbox)

      expect(doctor_inbox.reload.unread_messages_count).to eq(1)
      expect(patient_outbox.reload.sent_messages_count).to eq(1)
    end

    it 'decrements unread messages count in doctor’s inbox when a message is marked as read' do
      message = create(:message, outbox: patient_outbox, inbox: doctor_inbox)
      expect(doctor_inbox.reload.unread_messages_count).to eq(1)

      message.mark_as_read
      expect(doctor_inbox.reload.unread_messages_count).to eq(0)
    end
  end

  describe 'Performance with large datasets', :performance do
    let(:doctor) { create(:user, :doctor) }
    let(:patient) { create(:user, :patient) }
    let(:admin) { create(:user, :admin) }
    let(:doctor_inbox) { create(:inbox, user: doctor) }
    let(:patient_outbox) { create(:outbox, user: patient) }
    let(:doctor_outbox) { create(:outbox, user: doctor) }
    let(:patient_inbox) { create(:inbox, user: patient) }
    let(:admin_inbox) { create(:inbox, user: admin) }

    context 'when handling a large number of messages' do
      before do
        # Create a large number of messages
        10_000.times do
          create(:message, outbox: patient_outbox, inbox: doctor_inbox)
        end
      end

      it 'efficiently retrieves messages' do
        expect do
          messages = described_class.where(inbox: doctor_inbox).limit(100)
          messages.to_a # Force loading
        end.to perform_under(5).ms
      end

      it 'efficiently counts unread messages' do
        expect do
          doctor_inbox.reload.unread_messages_count
        end.to perform_under(10).ms
      end

      it 'efficiently marks messages as read' do
        unread_messages = described_class.where(inbox: doctor_inbox, read: false).limit(1000)

        expect do
          ActiveRecord::Base.transaction do
            unread_messages.update_all(read: true)
          end
          doctor_inbox.reload.unread_messages_count
        end.to perform_under(10).ms
      end
    end

    context 'when routing messages with a large inbox' do
      let(:default_admin) { create(:user, :admin) }
      
      before do
        # Create a large number of old messages
        10_000.times do
          create(:message, outbox: patient_outbox, inbox: doctor_inbox, created_at: 2.weeks.ago)
        end
        allow(User).to receive(:default_admin).and_return(default_admin)
        create(:inbox, user: default_admin)
      end

      it 'efficiently routes new messages to admin for old conversations' do
        create(:message, outbox: doctor_outbox, inbox: patient_inbox, created_at: 2.weeks.ago)
        old_message = described_class.where(inbox: patient_inbox).last

        new_message = described_class.create_reply(body: 'New reply', reply_to_id: old_message.id)

        expect do
          new_message
        end.to perform_under(50).ms

        expect(new_message.inbox.unread_messages_count).to eq(1)
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
