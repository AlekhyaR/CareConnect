# frozen_string_literal: true

module Payments
  class ReliablePaymentProvider
    class PaymentError < StandardError; end

    def debit(_amount)
      # Simulates a reliable payment provider that always processes the payment successfully
      true
    end
  end
end
