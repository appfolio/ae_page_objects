module AePageObjects
  module MultipleWindows
    class Window < AePageObjects::Window
      attr_reader :handle

      def initialize(browser, registry, handle)
        @registry = registry
        @handle   = handle

        @registry.add(self)

        super(browser)
      end

      def switch_to
        WindowHandleManager.switch_to(handle)
        @current_document
      end

      def close
        if WindowHandleManager.close(@handle)
          assign_current_document(nil)
          @registry.remove(self)
        end
      end
    end
  end
end