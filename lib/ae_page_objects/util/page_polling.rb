module AePageObjects
  module PagePolling
    # Quickly polls the block until it returns (as opposed to throwing an exception). Using poll
    # is a safer alternative to,
    #
    # Capybara.using_wait_time(0) do
    #   has_content?('Admin')
    # end
    #
    # where we want to determine whether 'Admin' is on the page (without waiting for it to appear).
    # This is often used to switch login / functionality of page objects based on the state of the
    # page.
    #
    # With poll, the above patterns becomes,
    #
    # AePageObjects.poll do
    #   has_content?('Admin')
    # end
    def poll(seconds_to_wait = nil, &block)
      result = nil
      poll_until(seconds_to_wait) do
        result = block.call
        true
      end
      result
    end

    # Quickly polls the block until it returns something truthy. This is a helper function for
    # special cases and probably NOT what you want to use. See AePageObjects#wait_until or
    # #poll.
    def poll_until(seconds_to_wait = nil, &block)
      AePageObjects.wait_until(seconds_to_wait) do
        # Capybara normally catches errors and retries. However, with the wait time of zero,
        # capybara catches the errors and immediately reraises them. So we have to catch
        # those errors in the similar fashion to capybara such that we properly can wait the
        # whole seconds_to_wait.
        begin
          Capybara.using_wait_time(0, &block)
        rescue => e
          raise unless catch_poll_until_error?(e)
          nil
        end
      end
    end

    def catch_poll_until_error?(error)
      types = Capybara.current_session.driver.invalid_element_errors + [Capybara::ElementNotFound]
      types.any? do |type|
        error.is_a?(type)
      end
    end
  end
end
