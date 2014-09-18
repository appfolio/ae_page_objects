module AePageObjects
  module MultipleWindows
    class Browser
      attr_reader :windows

      def initialize
        @windows = WindowList.new
      end

      def current_window
        @windows.current_window
      end

      def find_document(*document_classes, &block)
        query           = DocumentQuery.new(*document_classes, &block)
        document_loader = DocumentLoader.new(query, CrossWindowLoaderStrategy.new(@windows))
        loaded_page     = document_loader.load

        DocumentProxy.new(loaded_page, query)
      end
    end
  end
end
