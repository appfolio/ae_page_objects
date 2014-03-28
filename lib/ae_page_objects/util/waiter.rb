module AePageObjects
  module Waiter
    def self.wait_for(&block)
      seconds_to_wait = Capybara.default_wait_time
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
  end
end