require 'ae_page_objects'

module TestApp
  module PageObjects
    class Application < ::AePageObjects::Application

      # TODO - add something to config.paths to ensure it works
    end
  end
end

TestApp::PageObjects::Application.initialize!