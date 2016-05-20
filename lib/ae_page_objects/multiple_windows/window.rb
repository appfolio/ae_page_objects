require 'ae_page_objects/multiple_windows/window_handle_manager'

require 'ae_page_objects/single_window/window'

module AePageObjects
  module MultipleWindows
    SizeClass = Struct.new(:width, :height)

    class Window < SingleWindow::Window
      attr_reader :handle

      def initialize(registry, handle)
        super()

        @registry = registry
        @handle   = handle
        @registry.add(self)
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

      def size
        width, height = Capybara.current_session.driver.window_size(@handle)
        SizeClass.new(width, height)
      end

      protected

      def resize_window_to(width, height)
        Capybara.current_session.driver.resize_window_to(@handle, width, height)
      end
    end
  end
end
