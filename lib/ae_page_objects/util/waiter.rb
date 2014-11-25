module AePageObjects
  module Waiter
    def self.wait_until(timeout = nil, &block)
      seconds_to_wait = timeout || Capybara.default_wait_time
      start_time      = Time.now

      until result = Capybara.using_wait_time(0, &block)
        delay = seconds_to_wait - (Time.now - start_time)

        if delay <= 0
          return false
        end

        sleep(0.05)
        raise AePageObjects::FrozenInTime, "Time appears to be frozen" if Time.now == start_time
      end

      result
    end

    def self.wait_for(*args, &block)
      wait_until(*args, &block)
    end

    def self.wait_until!(timeout = nil)
      result = wait_until(timeout) do
        yield
      end

      unless result
        raise AePageObjects::WaitTimeoutError, "Timed out waiting for condition"
      end

      result
    end
  end
end
