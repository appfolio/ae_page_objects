require 'ae_page_objects/node'
require 'ae_page_objects/concerns/visitable'

module AePageObjects
  class Document < AePageObjects::Node
    include AePageObjects::Concerns::Visitable

    attr_reader :window

    def initialize
      super(Capybara.current_session)

      @window = browser.current_window
      @window.current_document = self
    end

    def browser
      AePageObjects.browser
    end

    def document
      self
    end

    class << self
    private
      def site
        @site ||= AePageObjects::Site.from(self)
      end
    end
  end
end
