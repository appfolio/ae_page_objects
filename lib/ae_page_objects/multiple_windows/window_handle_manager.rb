module AePageObjects
  module MultipleWindows
    class WindowHandleManager
      def self.all
        browser.window_handles
      end

      def self.current
        # Accessing browser.window_handle tries to find an existing page, which will blow up
        # if there isn't one. So... we look at the collection first as a guard.
        if all.empty?
          nil
        else
          browser.window_handle
        end
      rescue => e
        if Capybara.current_session.driver.is_a?(Capybara::Selenium::Driver) &&
           e.is_a?(Selenium::WebDriver::Error::NoSuchWindowError)
          raise WindowNotFound
        end

        raise
      end

      def self.switch_to(handle)
        browser.switch_to.window(handle)
      end

      def self.browser
        Capybara.current_session.driver.browser
      end

      def self.close(handle)
        all_handles_before_close = all()
        more_than_one_window     = (all_handles_before_close.size > 1)

        # We must protect against closing the last window as doing so will quit the entire browser
        # which would mess up subsequent tests.
        # http://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/WebDriver.html#close()
        return false unless more_than_one_window

        current_handle_before_switch = current

        # switch to the window to close
        switch_to(handle)

        browser.close

        # need to switch back to something. Use whatever was switched from originally unless we just
        # closed that window, in which case just pick something else.
        switch_to(current_handle_before_switch == handle ?  all.first : current_handle_before_switch)

        true
      end
    end
  end
end
