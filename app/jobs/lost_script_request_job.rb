# frozen_string_literal: true

class LostScriptRequestJob < ApplicationJob # rubocop:disable Style/Documentation
  queue_as :default

  def perform(prescription_id)
    @prescription = find_prescription(prescription_id)
    return unless @prescription

    process_lost_script_request
  rescue StandardError => e
    Rails.logger.error("Unexpected error occurred for prescription ID: #{prescription_id}. Error: #{e.message}")
  end

  private

  def find_prescription(prescription_id)
    Prescription.find_by(id: prescription_id).tap do |prescription|
      Rails.logger.error("Prescription with ID: #{prescription_id} not found") unless prescription
    end
  end

  def process_lost_script_request
    if request_successful?
      handle_success
    else
      handle_failure
    end
  end

  def request_successful?
    LostScriptRequestService.new(@prescription).call
  end

  def notification_service
    @notification_service ||= NotificationService.new(@prescription)
  end

  def handle_success
    notification_service.notify_of_success
    Rails.logger.info("Lost Script Request processed successfully for prescription ID: #{@prescription.id}")
  end

  def handle_failure
    notification_service.notify_of_failure
    Rails.logger.error("Lost Script Request failed for prescription ID: #{@prescription.id}")
  end
end
