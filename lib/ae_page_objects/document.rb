module AePageObjects
  class Document < Node
    include Concerns::Visitable
    
    def document
      self
    end
    
    class << self
      private
      def application
        @application ||= begin
          universe = AePageObjects::DependenciesHook.containing_page_object_universe(self)
          "#{universe.name}::Application".constantize.instance
        end
      end
    end
  end
end