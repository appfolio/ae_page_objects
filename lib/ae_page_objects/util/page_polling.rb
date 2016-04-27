module AePageObjects
  module PagePolling
    def poll_until(timeout = nil, &block)
      AePageObjects.wait_until(timeout) do
        Capybara.using_wait_time(0, &block)
      end
    end
  end
end
