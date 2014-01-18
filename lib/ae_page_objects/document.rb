module AePageObjects
  class Document < Node
    include Concerns::Visitable

    def initialize
      super(Capybara.current_session)
    end

    if defined? Selenium::WebDriver
      attr_reader :window
    
      def initialize
        super(Capybara.current_session)

        @window = Window.current
        @window.current_document = self
      end
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