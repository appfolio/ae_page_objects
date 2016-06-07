require 'ae_page_objects/multiple_windows/cross_window_loader_strategy'
require 'ae_page_objects/multiple_windows/window_list'

require 'ae_page_objects/document_loader'
require 'ae_page_objects/document_proxy'
require 'ae_page_objects/document_query'

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
