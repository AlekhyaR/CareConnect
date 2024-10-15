# frozen_string_literal: true

#
# Application supports multiple payment providers identified by id. Default one is very flaky one that sometimes processes payment and sometimes not. You
# call PaymentProviderFactory.provider(:flaky) to get instance of FlakyPaymentProvider. Or you can register other providers.
#
module Payments
  class PaymentProviderFactory
    class << self
      def register(id, provider_class)
        providers[id] = provider_class
      end

      def provider(id = nil)
        providers[id]&.new || default_provider
      end

      private

      def providers
        @providers ||= {
          flaky: Payments::FlakyPaymentProvider,
          reliable: Payments::ReliablePaymentProvider
        }
      end

      def default_provider
        providers[:flaky].new
      end
    end
  end
end
