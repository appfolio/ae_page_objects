module AePageObjects
  module Waiter
    def self.wait_until(timeout = nil, &block)
      wait_until!(timeout, &block)
    rescue WaitTimeoutError
      false
    end

    def self.wait_for(*args, &block)
      warn "[DEPRECATION WARNING]: AePageObjects::Waiter.wait_for is deprecated and will be removed in version 2.0.0. Use AePageObjects::Waiter.wait_until instead."
      wait_until(*args, &block)
    end

    def self.wait_until!(timeout = nil, &block)
      AePageObjects.wait_until(timeout) do
        Capybara.using_wait_time(0, &block)
      end
    end
  end
end
