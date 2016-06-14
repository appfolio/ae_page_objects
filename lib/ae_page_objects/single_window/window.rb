require 'ae_page_objects/single_window/same_window_loader_strategy'

require 'ae_page_objects/document_loader'
require 'ae_page_objects/document_proxy'
require 'ae_page_objects/document_query'

module AePageObjects
  WindowDimension = Struct.new(:width, :height)

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

      def dimension
        to_dimension(*capybara_window.size)
      end

      def resize_to(width: nil, height: nil)
        original_dimension = dimension;
        width ||= original_dimension.width
        height ||= original_dimension.height

        set_window_width_and_height(width, height)
        original_dimension
      end

      def with_dimension(width: nil, height: nil)
        original_dimension = resize_to(width: width, height: height)

        yield if block_given?
      ensure
        resize_to(width: original_dimension.width, height: original_dimension.height)
      end

      private

      def to_dimension(width, height)
        WindowDimension.new(width, height)
      end

      def set_window_width_and_height(width, height)
        capybara_window.resize_to(width, height)
      end

      def capybara_window
        Capybara.current_session.driver.browser.manage.window
      end
    end
  end
end
