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

      def size
        capybara_window.size
      end

      def resize_to(width = nil, height = nil)
        original_size = size;
        width, height = normalize_size(width, height, original_size)

        resize_window_to(width, height)
        original_size
      end

      def with_window_size(width = nil, height = nil)
        original_size = resize_to(width, height)

        yield if block_given?
      ensure
        resize_to(original_size.width, original_size.height)
      end

      protected

      def resize_window_to(width, height)
        capybara_window.resize_to(width, height)
      end

      private

      def capybara_window
        Capybara.current_session.driver.browser.manage.window
      end

      def normalize_size(width, height, default_size)
        width ||= default_size.width
        height ||= default_size.height
        [width, height]
      end
    end
  end
end
