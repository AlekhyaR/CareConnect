require 'rails_helper'

RSpec.describe LostScriptRequestJob, type: :job do
  let(:prescription) { create(:prescription) }
  let(:notification_service) { instance_double(NotificationService) }
  let(:lost_script_request_service) { instance_double(LostScriptRequestService) }

  before do
    # Mock external services
    allow(LostScriptRequestService).to receive(:new).and_return(lost_script_request_service)
    allow(NotificationService).to receive(:new).and_return(notification_service)
    allow(notification_service).to receive(:notify_of_success)
    allow(notification_service).to receive(:notify_of_failure)

    # Stub Rails logger
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  describe '#perform' do
    context 'when the prescription is found' do
      before do
        allow(Prescription).to receive(:find_by).and_return(prescription)
      end

      context 'when the request is successful' do
        before do
          allow(lost_script_request_service).to receive(:call).and_return(true)
        end

        it 'calls handle_success' do
          expect_any_instance_of(described_class).to receive(:handle_success)

          described_class.perform_now(prescription.id)
        end

        it 'sends a success notification' do
          described_class.perform_now(prescription.id)

          expect(notification_service).to have_received(:notify_of_success).once
        end

        it 'logs success message' do
          described_class.perform_now(prescription.id)

          expect(Rails.logger).to have_received(:info).with("Lost Script Request processed successfully for prescription ID: #{prescription.id}")
        end
      end

      context 'when the request is unsuccessful' do
        before do
          allow(lost_script_request_service).to receive(:call).and_return(false)
        end

        it 'calls handle_failure' do
          expect_any_instance_of(described_class).to receive(:handle_failure)

          described_class.perform_now(prescription.id)
        end

        it 'sends a failure notification' do
          described_class.perform_now(prescription.id)

          expect(notification_service).to have_received(:notify_of_failure).once
        end

        it 'logs failure message' do
          described_class.perform_now(prescription.id)

          expect(Rails.logger).to have_received(:error).with("Lost Script Request failed for prescription ID: #{prescription.id}")
        end
      end
    end

    context 'when the prescription is not found' do
      before do
        allow(Prescription).to receive(:find_by).and_return(nil)
      end

      it 'does not process the request' do
        expect(lost_script_request_service).not_to receive(:call)

        described_class.perform_now(1)
      end

      it 'logs an error message' do
        described_class.perform_now(1)

        expect(Rails.logger).to have_received(:error).with("Prescription with ID: 1 not found")
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Prescription).to receive(:find_by).and_return(prescription)
        allow(lost_script_request_service).to receive(:call).and_raise(StandardError, 'Unexpected error')
      end

      it 'logs the unexpected error' do
        described_class.perform_now(prescription.id)

        expect(Rails.logger).to have_received(:error).with("Unexpected error occurred for prescription ID: #{prescription.id}. Error: Unexpected error")
      end
    end
  end
end
