# frozen_string_literal: true

class LostScriptRequestService # rubocop:disable Style/Documentation
  MAX_ATTEMPTS = 3
  PAYMENT_AMOUNT = 10

  def initialize(prescription)
    @prescription = prescription
    @admin = User.admin.first
    @patient = @prescription.patient
    @flaky_payment_provider = Payments::PaymentProviderFactory.provider(:flaky)
    @reliable_payment_provider = Payments::PaymentProviderFactory.provider(:reliable)
  end

  def call
    return false unless notify_admin

    process_payment_and_update_status
  end

  private

  def notify_admin
    Message.notify_admin_of_prescription_request(
      User.current,
      @admin,
      I18n.t('messages.re-issue.admin'),
      @prescription.id
    )
  end

  def process_payment_and_update_status
    update_prescription_status(I18n.t('user.patient.reissue_request_sent'))
    payment_status = attempt_payment
    create_payment_record(payment_status)
    payment_status == 'Succeeded'
  end

  def attempt_payment
    update_prescription_status(I18n.t('payment.in_process'))

    status = try_payment_with(@flaky_payment_provider)
    return status if status == 'Succeeded'

    status = try_payment_with(@reliable_payment_provider)
    return status if status == 'Succeeded'

    handle_payment_failure
  end

  def try_payment_with(provider)
    MAX_ATTEMPTS.times do |attempt|
      log_payment_attempt(provider, attempt)
      begin
        provider.debit(PAYMENT_AMOUNT)
        return handle_payment_success
      rescue Payments::FlakyPaymentProvider::PaymentError, Payments::ReliablePaymentProvider::PaymentError => e
        log_payment_error(provider, attempt, e)
      end
    end
    'Failed'
  end

  def handle_payment_success
    update_prescription_status(I18n.t('payment.success'))
    'Succeeded'
  end

  def handle_payment_failure
    update_prescription_status(I18n.t('payment.failed'))
    'Failed'
  end

  def create_payment_record(status)
    Payment.create(
      user: User.current,
      amount: PAYMENT_AMOUNT,
      prescription_id: @prescription.id,
      payment_type: 'lost_script_request',
      status:
    )
  end

  def update_prescription_status(status)
    @prescription.update(status:)
  end

  def log_payment_attempt(provider, attempt)
    Rails.logger.info("Attempt #{attempt + 1} with #{provider}")
  end

  def log_payment_error(provider, attempt, error)
    Rails.logger.error("Payment attempt #{attempt + 1} failed with #{provider}: #{error.message}")
  end
end
