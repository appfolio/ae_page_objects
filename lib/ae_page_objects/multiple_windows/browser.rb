module AePageObjects
  module MultipleWindows
    class Browser
      attr_reader :windows

      def initialize
        @windows = AePageObjects::MultipleWindows::WindowList.new
      end

      def current_window
        @windows.current_window
      end

      def find_document(*document_classes, &block)
        query           = AePageObjects::DocumentQuery.new(*document_classes, &block)
        document_loader = AePageObjects::DocumentLoader.new(query, AePageObjects::MultipleWindows::CrossWindowLoaderStrategy.new(@windows))
        loaded_page     = document_loader.load

        AePageObjects::DocumentProxy.new(loaded_page, query)
      end
    end
  end
end
