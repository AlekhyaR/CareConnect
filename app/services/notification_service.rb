# frozen_string_literal: true

class NotificationService
  def initialize(prescription)
    @prescription = prescription
  end

  def notify_of_success
    notify_patient_of_success
    notify_admin_of_success
  end

  def notify_of_failure
    notify_patient_of_failure
    notify_admin_of_failure
  end

  private

  def notify_patient_of_success
    send_email(:patient_reissue_success)
  end

  def notify_patient_of_failure
    send_email(:patient_reissue_failure)
  end

  def notify_admin_of_success
    send_email(:admin_reissue_success)
  end

  def notify_admin_of_failure
    send_email(:admin_request_failure)
  end

  def send_email(mailer_method)
    UserMailer.with(prescription: @prescription).public_send(mailer_method).deliver_later
  rescue StandardError => e
    log_error(mailer_method, e)
  end

  def log_error(mailer_method, error)
    message = "Failed to send #{mailer_method} for prescription ID: #{@prescription.id}. Error: #{error.message}"
    Rails.logger.error(message)
  end
end
