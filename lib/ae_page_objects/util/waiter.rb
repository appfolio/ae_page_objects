module AePageObjects
  module Waiter
    def self.wait_for(&block)
      Timeout.timeout(Capybara.default_wait_time) do
        sleep(0.05) until value = Capybara.using_wait_time(0, &block)
        value
      end
    rescue Timeout::Error
      false
    end
  end
end
