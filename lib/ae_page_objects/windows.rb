module AePageObjects
  class Windows
    def initialize
      @windows = {}
    end

    def add(window)
      @windows[window.handle] = window
    end

    def remove(window)
      @windows.delete(window.handle)
    end

    def opened_windows
      Window::HandleManager.all.map do |handle|
        find(handle)
      end
    end

    def current_window
      current_handle = Window::HandleManager.current

      find(current_handle) if current_handle
    end

    def close_all
      opened_windows.each(&:close)
    end

  private

    def find(handle)
      @windows[handle] || create_window(handle)
    end

    def create_window(handle)
      Window.new(self, handle)
    end
  end
end