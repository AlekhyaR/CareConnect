# frozen_string_literal: true

module Payments
  class FlakyPaymentProvider # rubocop:disable Style/Documentation
    class PaymentError < StandardError; end

    def debit(_amount)
      # This is simulating flaky API on the other side that can sometimes respond with an error
      raise PaymentError, I18n.t('payment.flaky.error', amount: 10) unless Time.current.to_i.even?

      true
    end
  end
end
