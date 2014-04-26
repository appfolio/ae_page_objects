module AePageObjects
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
      query           = DocumentQuery.new(*document_classes, &block)
      document_loader = DocumentLoader.new(query, DocumentLoader::SameWindowLoaderStrategy.new)

      DocumentProxy.new(document_loader.load, document_loader)
    end

    if MULTIPLE_WINDOWS_SUPPORT
      require 'ae_page_objects/window/handle_manager'

      attr_reader :handle

      def initialize(registry, handle)
        @registry         = registry
        @handle           = handle
        @current_document = nil

        @registry.add(self)
      end

      def switch_to
        HandleManager.switch_to(handle)
        current_document
      end

      def close
        if HandleManager.close(@handle)
          self.current_document = nil
          @registry.remove(self)
        end
      end

      class << self
        def all
          warn "[DEPRECATION WARNING]: AePageObjects::Window.all is deprecated. Use Browser.instance.windows."
          @windows ||= Browser.instance.windows
        end

        def close_all
          warn "[DEPRECATION WARNING]: AePageObjects::Window.close_all is deprecated. Use Browser.instance.windows.close_all."
          all.close_all
        end
      end
    end
  end
end
