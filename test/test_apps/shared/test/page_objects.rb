require 'ae_page_objects'

ActiveSupport::Dependencies.autoload_paths << "test"

module PageObjects
  class Site < AePageObjects::Site
  end
end

PageObjects::Site.initialize!
