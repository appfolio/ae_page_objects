module AePageObjects
  module SingleWindow
    class Window
      attr_reader :current_document

      def initialize
        @current_document = nil
      end

      def current_document=(document)
        @current_document.send(:stale!) if @current_document
        @current_document = document
      end

      def change_to(*document_classes, &block)
        query           = AePageObjects::DocumentQuery.new(*document_classes, &block)
        document_loader = AePageObjects::DocumentLoader.new(query, AePageObjects::SingleWindow::SameWindowLoaderStrategy.new)
        loaded_page     = document_loader.load

        AePageObjects::DocumentProxy.new(loaded_page, query)
      end
    end
  end
end
