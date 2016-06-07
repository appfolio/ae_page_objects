require 'capybara'
require 'capybara/dsl'

require 'ae_page_objects/version'
require 'ae_page_objects/exceptions'

module AePageObjects
  autoload :Node,              'ae_page_objects/node'
  autoload :Document,          'ae_page_objects/document'
  autoload :Element,           'ae_page_objects/element'

  autoload :Collection,        'ae_page_objects/elements/collection'
  autoload :Form,              'ae_page_objects/elements/form'
  autoload :Select,            'ae_page_objects/elements/select'
  autoload :Checkbox,          'ae_page_objects/elements/checkbox'

  class << self
    attr_accessor :default_router

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

    def wait_until(seconds_to_wait = nil, error_message = nil)
      seconds_to_wait ||= default_max_wait_time
      start_time      = Time.now

      until result = yield
        delay = seconds_to_wait - (Time.now - start_time)

        if delay <= 0
          raise WaitTimeoutError, error_message || "Timed out waiting for condition"
        end

        sleep(0.05)
        raise FrozenInTime, "Time appears to be frozen" if Time.now == start_time
      end

      result
    end

    private

    def default_max_wait_time
      if Capybara.respond_to?(:default_max_wait_time)
        Capybara.default_max_wait_time
      else
        Capybara.default_wait_time
      end
    end
  end
end

require 'ae_page_objects/core/basic_router'
AePageObjects.default_router = AePageObjects::BasicRouter.new
