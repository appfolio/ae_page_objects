require 'capybara'
require 'capybara/dsl'

require 'ae_page_objects/version'
require 'ae_page_objects/exceptions'

require 'ae_page_objects/util/singleton'
require 'ae_page_objects/util/internal_helpers'
require 'ae_page_objects/util/hash_symbolizer'
require 'ae_page_objects/util/inflector'
require 'ae_page_objects/util/waiter'

require 'ae_page_objects/core/universe'
require 'ae_page_objects/core/site'
require 'ae_page_objects/core/basic_router'
require 'ae_page_objects/core/application_router'
require 'ae_page_objects/core/rake_router'
require 'ae_page_objects/core/dsl'

require 'ae_page_objects/core_ext/module'

require 'ae_page_objects/concerns/load_ensuring'
require 'ae_page_objects/concerns/staleable'
require 'ae_page_objects/concerns/visitable'

require 'ae_page_objects/single_window/browser'
require 'ae_page_objects/single_window/window'
require 'ae_page_objects/single_window/same_window_loader_strategy'

require 'ae_page_objects/multiple_windows/browser'
require 'ae_page_objects/multiple_windows/window'
require 'ae_page_objects/multiple_windows/cross_window_loader_strategy'
require 'ae_page_objects/multiple_windows/window_list'
require 'ae_page_objects/multiple_windows/window_handle_manager'

module AePageObjects
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
end

require 'ae_page_objects/window'

require 'ae_page_objects/document_query'
require 'ae_page_objects/document_loader'

require 'ae_page_objects/node'
require 'ae_page_objects/document'
require 'ae_page_objects/document_proxy'
require 'ae_page_objects/element'
require 'ae_page_objects/element_proxy'

require 'ae_page_objects/elements/collection'
require 'ae_page_objects/elements/form'
require 'ae_page_objects/elements/select'
require 'ae_page_objects/elements/checkbox'


