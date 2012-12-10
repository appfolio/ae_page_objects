require 'ae_page_objects'

module TestApp
  module PageObjects
    class Application < ::AePageObjects::Application
    end
  end
end

TestApp::PageObjects::Application.initialize!