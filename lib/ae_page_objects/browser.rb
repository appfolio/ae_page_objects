module AePageObjects
  class Browser
    class << self
      def instance
        @instance ||= new
      end
    end

    if WINDOWS_SUPPORTED
      def find_document(*document_classes, &block)
        query       = DocumentQuery.new(*document_classes, &block)
        page_loader = PageLoader.new(query, PageLoader::CrossWindow.new(Window.all))
        DocumentProxy.new(page_loader)
      end
    end
  end
end