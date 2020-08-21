require 'capybara'
require 'capybara/dsl'

require 'ae_page_objects/version'
require 'ae_page_objects/exceptions'
require 'ae_page_objects/util/wait_time_manager'

module AePageObjects
  autoload :Node,              'ae_page_objects/node'
  autoload :Document,          'ae_page_objects/document'
  autoload :Element,           'ae_page_objects/element'

  autoload :Collection,        'ae_page_objects/elements/collection'
  autoload :Form,              'ae_page_objects/elements/form'
  autoload :Select,            'ae_page_objects/elements/select'
  autoload :Checkbox,          'ae_page_objects/elements/checkbox'

  class << self
    attr_accessor :default_router, :time_keeper

    def browser
      @browser ||= begin
        driver = Capybara.current_session.driver

        case driver
        when Capybara::Selenium::Driver then
          require 'ae_page_objects/multiple_windows/browser'
          MultipleWindows::Browser.new
        else
          require 'ae_page_objects/single_window/browser'
          SingleWindow::Browser.new
        end
      end
    end

    def wait_until(seconds_to_wait = nil, error_message = nil, &block)
      @wait_until ||= 0
      @wait_until += 1

      result = nil

      if @wait_until > 1
        # We want to ensure that only the top-level wait_until does the waiting error handling,
        # which allows correct timing and best chance of recovering from an error.
        result = call_wait_until_block(error_message, &block)
      else
        seconds_to_wait ||= default_max_wait_time
        start_time      = AePageObjects.time_keeper.now

        # In an effort to avoid flakiness, Capybara waits, rescues errors, reloads nodes, and
        # retries.
        #
        # There are cases when Capybara will rescue an error and either nodes are not
        # reloadable or the DOM has changed in a such a way that no amount of reloading will
        # help (but perhaps a retry at the higher level may have a chance of success). This leads
        # to us needless waiting for a long time just to fail.
        #
        # There are also cases when Selenium will take such a long time to respond with an error
        # that Capybara's timeout will be exceeded and no reloading / retrying will occur. Instead,
        # Capabara will just raise the error.
        #
        # In order to combat the two cases, we start with a lower Capybara wait time and increase
        # it each iteration. This logic is encapsulated in a little utility class.
        time_manager = WaitTimeManager.new(1.0, seconds_to_wait)
        begin
          result = time_manager.using_wait_time { call_wait_until_block(error_message, &block) }
        rescue => e
          errors = Capybara.current_session.driver.invalid_element_errors
          errors += [Capybara::ElementNotFound]
          errors += [DocumentLoadError, LoadingElementFailed, LoadingPageFailed]
          errors += [WaitTimeoutError]
          raise e unless errors.include?(e.class)

          delay = seconds_to_wait - (AePageObjects.time_keeper.now - start_time)

          if delay <= 0
            # Raising the WaitTimeoutError in the rescue block ensures that Ruby attaches
            # the original exception as the cause for our WaitTimeoutError.
            raise WaitTimeoutError, e.message
          end

          sleep(0.05)
          raise FrozenInTime, "Time appears to be frozen" if AePageObjects.time_keeper.now == start_time

          retry
        end
      end

      result
    ensure
      @wait_until -= 1
    end

    private

    def call_wait_until_block(error_message, &block)
      result = block.call
      result ? result : raise(WaitTimeoutError, error_message || "Timed out waiting for condition")
    end

    def default_max_wait_time
      Capybara.default_max_wait_time
    end
  end
end

require 'ae_page_objects/core/basic_router'
AePageObjects.default_router = AePageObjects::BasicRouter.new
AePageObjects.time_keeper = Time
