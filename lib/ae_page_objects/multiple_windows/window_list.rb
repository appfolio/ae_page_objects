module AePageObjects
  module MultipleWindows
    class WindowList
      def initialize(browser)
        @browser = browser
        @windows = {}
      end

      def add(window)
        @windows[window.handle] = window
      end

      def remove(window)
        @windows.delete(window.handle)
      end

      def opened
        WindowHandleManager.all.map do |handle|
          find(handle)
        end
      end

      def current_window
        current_handle = WindowHandleManager.current

        find(current_handle) if current_handle
      end

      def close_all
        opened.each(&:close)
      end

    private

      def find(handle)
        @windows[handle] || create_window(handle)
      end

      def create_window(handle)
        Window.new(@browser, self, handle)
      end
    end
  end
end