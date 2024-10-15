# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LostScriptRequestService, type: :service do
  let(:prescription) { create(:prescription) }
  let(:patient) { prescription.patient }
  let(:admin) { create(:user, :admin) }
  let(:flaky_provider) { double('FlakyPaymentProvider') }
  let(:reliable_provider) { double('ReliablePaymentProvider') }
  let(:message_body) { I18n.t('messages.re-issue.admin') }
  let(:service) { described_class.new(prescription) }

  before do
    allow(Payments::PaymentProviderFactory).to receive(:provider).with(:flaky).and_return(flaky_provider)
    allow(Payments::PaymentProviderFactory).to receive(:provider).with(:reliable).and_return(reliable_provider)
    allow(User).to receive_messages(admin: [admin], current: patient)
  end

  describe '#call' do
    context 'when a lost script message is sent to the admin and payment succeeds' do
      before do
        allow(flaky_provider).to receive(:debit).and_raise(Payments::FlakyPaymentProvider::PaymentError)
        allow(reliable_provider).to receive(:debit).and_return(true)
      end

      it 'sends a message to the admin' do
        expect(Message).to receive(:notify_admin_of_prescription_request).with(
          patient, admin, message_body, prescription.id
        ).and_call_original

        described_class.new(prescription).call
      end

      it 'calls the Payment API and creates a Payment record with "Succeeded" status' do
        expect { described_class.new(prescription).call }.to change(Payment, :count).by(1)

        payment = Payment.last
        expect(payment.user).to eq(patient)
        expect(payment.prescription_id).to eq(prescription.id)
        expect(payment.status).to eq('Succeeded')
        expect(payment.payment_type).to eq('lost_script_request')
      end
    end

    context 'when the Payment API call fails' do
      before do
        allow(flaky_provider).to receive(:debit).and_raise(Payments::FlakyPaymentProvider::PaymentError)
        allow(reliable_provider).to receive(:debit).and_raise(Payments::ReliablePaymentProvider::PaymentError)
      end

      it 'retries the flaky provider up to MAX_ATTEMPTS' do
        expect(flaky_provider).to receive(:debit).exactly(LostScriptRequestService::MAX_ATTEMPTS).times
        expect(reliable_provider).to receive(:debit).exactly(LostScriptRequestService::MAX_ATTEMPTS).times

        service.call
      end

      it 'creates a Payment record with "Failed" status and gracefully degrades' do
        expect { described_class.new(prescription).call }.to change(Payment, :count).by(1)

        payment = Payment.last
        expect(payment.user).to eq(patient)
        expect(payment.prescription_id).to eq(prescription.id)
        expect(payment.status).to eq('Failed')
        expect(payment.payment_type).to eq('lost_script_request')
      end

      it 'marks the payment as failed if all attempts with both providers fail' do
        expect(service).to receive(:update_prescription_status).with(I18n.t('user.patient.reissue_request_sent')).ordered
        expect(service).to receive(:update_prescription_status).with(I18n.t('payment.in_process')).ordered
        expect(service).to receive(:update_prescription_status).with(I18n.t('payment.failed')).ordered

        result = service.call

        expect(result).to be_falsey
      end

      it 'updates the prescription status to "Payment Failed"' do
        service = described_class.new(prescription)
        service.call

        expect(prescription.reload.status).to eq(I18n.t('payment.failed'))
      end
    end
  end
end
