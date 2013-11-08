module AePageObjects
  class Document < Node
    include Concerns::Visitable

    class << self
      def find(*args, &block)
        DocumentFinder.new(self).find(*args, &block)
      end

    private

      def site
        @site ||= AePageObjects::Site.from(self)
      end
    end

    attr_reader :window
    
    def initialize
      super(Capybara.current_session)

      @window = Window.current
      @window.current_document = self
    end
    
    def document
      self
    end
  end
end
