require 'ae_page_objects/single_window/same_window_loader_strategy'

require 'ae_page_objects/document_loader'
require 'ae_page_objects/document_proxy'
require 'ae_page_objects/document_query'

module AePageObjects
  module SingleWindow
    class Window
      attr_reader :current_document

      def initialize
        @current_document = nil
      end

      def current_document=(document)
        @current_document.stale! if @current_document
        @current_document = document
      end

      def change_to(*document_classes, &block)
        query           = DocumentQuery.new(*document_classes, &block)
        document_loader = DocumentLoader.new(query, SameWindowLoaderStrategy.new)
        loaded_page     = document_loader.load

        DocumentProxy.new(loaded_page, query)
      end
    end
  end
end
