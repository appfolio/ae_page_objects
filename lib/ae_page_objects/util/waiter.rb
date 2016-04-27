module AePageObjects
  module Waiter
    class << self
      def wait_until(timeout = nil, &block)
        warn "[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead."
        wait_until_return_false(timeout, &block)
      end

      def wait_for(timeout = nil, &block)
        warn "[DEPRECATION WARNING]: AePageObjects::Waiter.wait_for is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead."
        wait_until_return_false(timeout, &block)
      end

      def wait_until!(timeout = nil, &block)
        warn "[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until! is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead."
        AePageObjects.poll_until(timeout, &block)
      end

      private

      def wait_until_return_false(timeout, &block)
        AePageObjects.poll_until(timeout, &block)
      rescue WaitTimeoutError
        false
      end
    end
  end
end
