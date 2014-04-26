module AePageObjects
  class Browser
    class << self
      def instance
        @instance ||= new
      end
    end

    def current_window
      @current_window ||= Window.new
    end

    if MULTIPLE_WINDOWS_SUPPORT
      require 'ae_page_objects/window_list'

      attr_reader :windows

      def initialize
        @windows = WindowList.new
      end

      def current_window
        @windows.current_window
      end

      def find_document(*document_classes, &block)
        query       = DocumentQuery.new(*document_classes, &block)
        page_loader = PageLoader.new(query, PageLoader::CrossWindow.new(@windows))

        DocumentProxy.new(page_loader.load_page, page_loader)
      end
    end
  end
end