module AePageObjects
  class Document < Node
    include Concerns::Visitable
    
    def initialize
      super(Capybara.current_session)

      AePageObjects::Application.current_document = self
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