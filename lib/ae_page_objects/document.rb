module AePageObjects
  class Document < Node
    include Concerns::Visitable

    def initialize
      super(Capybara.current_session)
    end

    if WINDOWS_SUPPORTED
      attr_reader :window
    
      def initialize
        super(Capybara.current_session)

        @window = Window.current
        @window.current_document = self
      end

      class << self
        def find(*args, &block)
          DocumentFinder.new(self).find(*args, &block)
        end
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
