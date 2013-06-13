module AePageObjects
  class Document < Node
    include Concerns::Visitable

    attr_reader :window
    
    def initialize
      super(Capybara.current_session)

      @window = Window.current
      @window.current_document = self
    end
    
    def document
      self
    end
    
    class << self
    private
      def application
        @application ||= AePageObjects::Application.from(self)
      end
    end
  end
end