module AePageObjects
  class Document < Node
    include Concerns::Visitable
    
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