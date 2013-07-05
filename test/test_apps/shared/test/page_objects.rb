require 'ae_page_objects'

ActiveSupport::Dependencies.autoload_paths << "test"

module PageObjects
  class Application < ::AePageObjects::Application
  end
end

PageObjects::Application.initialize!