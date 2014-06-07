module AePageObjects
  module MultipleWindows
    class WindowList
      def initialize
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
          window_for(handle)
        end
      end

      def current_window
        current_handle = WindowHandleManager.current

        window_for(current_handle) if current_handle
      rescue WindowNotFound
        synchronize_windows

        if current_window = @windows[@windows.keys.sort.first]
          current_window.switch_to
          current_window
        end
      end

      def close_all
        opened.each(&:close)
      end

    private

      def synchronize_windows
        existence_unverified_window_handles = @windows.keys

        WindowHandleManager.all.map do |handle|
          # If it exists in the browser, it's been verified
          existence_unverified_window_handles.delete(handle)
        end

        # Remove the windows that no longer exist.
        existence_unverified_window_handles.each do |non_existing_window_handle|
          @windows.delete(non_existing_window_handle)
        end
      end

      def window_for(handle)
        @windows[handle] ||= Window.new(self, handle)
      end
    end
  end
end