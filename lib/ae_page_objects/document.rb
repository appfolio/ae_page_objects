module AePageObjects
  class Document < Node
    include Concerns::Visitable
    
    def initialize
      super
      
      AePageObjects::Application.current_document = self
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