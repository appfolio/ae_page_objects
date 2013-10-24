module AePageObjects
  class Window
    class Registry < Hash
      def [](window_or_handle)
        if window_or_handle.is_a?(Window)
          super(window_or_handle.handle)
        else
          super(window_or_handle)
        end
      end

      def add(window)
        self[window.handle] = window
      end

      def remove(window)
        self.delete(window.handle)
      end
    end

    class << self
      def registry
        @registry ||= Registry.new
      end

      def current
        current_handle = Capybara.current_session.driver.browser.window_handle

        registry[current_handle] || create(current_handle)
      end

      def create(handle)
        new(registry, handle)
      end
    end

    attr_reader :current_document, :handle

    def initialize(registry, handle)
      @registry         = registry
      @handle           = handle
      @current_document = nil

      @registry.add(self)
    end

    def current_document=(document)
      @current_document.send(:stale!) if @current_document
      @current_document = document
    end

    def switch_to
      switch_to_window
      current_document
    end

    def close
      @registry.remove(self)

      self.current_document = nil

      switch_to_window do
        Capybara.current_session.execute_script("window.close();")
      end
    end

  private
    def switch_to_window(&block)
      Capybara.current_session.driver.browser.switch_to.window(handle, &block)
    end
  end
end