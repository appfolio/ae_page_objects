require 'capybara'
require 'capybara/dsl'

require 'ae_page_objects/version'
require 'ae_page_objects/exceptions'

module AePageObjects
  autoload :Universe,             'ae_page_objects/core/universe'
  autoload :Site,                 'ae_page_objects/core/site'
  autoload :BasicRouter,          'ae_page_objects/core/basic_router'
  autoload :ApplicationRouter,    'ae_page_objects/core/application_router'
  autoload :Dsl,                  'ae_page_objects/core/dsl'

  autoload :Singleton,            'ae_page_objects/util/singleton'
  autoload :InternalHelpers,      'ae_page_objects/util/internal_helpers'
  autoload :HashSymbolizer,       'ae_page_objects/util/hash_symbolizer'
  autoload :Inflector,            'ae_page_objects/util/inflector'
  autoload :Waiter,               'ae_page_objects/util/waiter'

  module MultipleWindows
    autoload :Browser,                   'ae_page_objects/multiple_windows/browser'
    autoload :Window,                    'ae_page_objects/multiple_windows/window'
    autoload :CrossWindowLoaderStrategy, 'ae_page_objects/multiple_windows/cross_window_loader_strategy'
    autoload :WindowList,                'ae_page_objects/multiple_windows/window_list'
    autoload :WindowHandleManager,       'ae_page_objects/multiple_windows/window_handle_manager'
  end

  module SingleWindow
    autoload :Browser,                   'ae_page_objects/single_window/browser'
    autoload :Window,                    'ae_page_objects/single_window/window'
    autoload :SameWindowLoaderStrategy,  'ae_page_objects/single_window/same_window_loader_strategy'
  end

  autoload :Window,            'ae_page_objects/window'

  autoload :DocumentQuery,     'ae_page_objects/document_query'
  autoload :DocumentLoader,    'ae_page_objects/document_loader'

  autoload :Node,              'ae_page_objects/node'
  autoload :Document,          'ae_page_objects/document'
  autoload :DocumentProxy,     'ae_page_objects/document_proxy'
  autoload :Element,           'ae_page_objects/element'
  autoload :ElementProxy,      'ae_page_objects/element_proxy'

  autoload :Collection,        'ae_page_objects/elements/collection'
  autoload :Form,              'ae_page_objects/elements/form'
  autoload :Select,            'ae_page_objects/elements/select'
  autoload :Checkbox,          'ae_page_objects/elements/checkbox'

  def self.browser
    @browser ||= begin
      driver = Capybara.current_session.driver

      case driver
      when Capybara::Selenium::Driver then
        MultipleWindows::Browser.new
      else
        SingleWindow::Browser.new
      end
    end
  end

  def self.wait_until(seconds_to_wait = nil, error_message = nil)
    seconds_to_wait ||= Capybara.default_wait_time
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
end

require 'ae_page_objects/core_ext/module'










