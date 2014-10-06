module AePageObjects
  module Waiter
    def self.wait_for(wait_time = nil, &block)
      seconds_to_wait = wait_time || Capybara.default_wait_time
      start_time      = Time.now

      until result = Capybara.using_wait_time(0, &block)
        delay = seconds_to_wait - (Time.now - start_time)

        if delay <= 0
          return false
        end

        sleep(0.05)
      end

      result
    end

    def self.wait_for!(wait_time = nil)
      result = wait_for(wait_time) do
        yield
      end

      unless result
        raise WaitTimeoutError, "Timed out waiting for condition"
      end

      result
    end
  end
end
