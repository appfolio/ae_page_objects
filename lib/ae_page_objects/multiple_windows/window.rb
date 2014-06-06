module AePageObjects
  module MultipleWindows
    class Window < SingleWindow::Window
      attr_reader :handle

      def initialize(registry, handle)
        @registry = registry
        @handle   = handle

        @registry.add(self)

        super()
      end

      def switch_to
        WindowHandleManager.switch_to(handle)
        current_document
      end

      def close
        if WindowHandleManager.close(@handle)
          self.current_document = nil
          @registry.remove(self)
        end
      end
    end
  end
end