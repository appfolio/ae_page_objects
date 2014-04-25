module AePageObjects
  class Browser
    class << self
      def instance
        @instance ||= new
      end
    end

    if WINDOWS_SUPPORTED
      attr_reader :windows

      def initialize
        @windows = WindowList.new
      end

      def find_document(*document_classes, &block)
        query       = DocumentQuery.new(*document_classes, &block)
        page_loader = PageLoader.new(query, PageLoader::CrossWindow.new(@windows))
        DocumentProxy.new(page_loader)
      end
    end
  end
end