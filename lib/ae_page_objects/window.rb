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

    class HandleManager
      extend CapybaraDelegates

      def self.all
        browser.window_handles
      end

      def self.current
        # Accessing browser.window_handle tries to find an existing page, which will blow up
        # if there isn't one. So... we look at the collection first as a guard.
        if all.empty?
          nil
        else
          browser.window_handle
        end
      end

      def self.switch_to(handle)
        browser.switch_to.window(handle)
      end

      def self.close(handle)
        all_handles_before_close = all()
        more_than_one_window     = (all_handles_before_close.size > 1)

        # We must protect against closing the last window as doing so will quit the entire browser
        # which would mess up subsequent tests.
        # http://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/WebDriver.html#close()
        return false unless more_than_one_window

        current_handle_before_switch = current

        # switch to the window to close
        switch_to(handle)

        browser.close

        # need to switch back to something. Use whatever was switched from originally unless we just
        # closed that window, in which case just pick something else.
        switch_to(current_handle_before_switch == handle ?  all.first : current_handle_before_switch)

        true
      end
    end

    class << self
      def registry
        @registry ||= Registry.new
      end

      def close_all
        all.each(&:close)
      end

      def all
        HandleManager.all.map do |handle|
          find(handle)
        end
      end

      def find(handle)
        registry[handle] || create(handle)
      end

      def current
        current_handle = HandleManager.current

        find(current_handle) if current_handle
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
      HandleManager.switch_to(handle)
      current_document
    end

    def close
      if HandleManager.close(@handle)
        self.current_document = nil
        @registry.remove(self)
      end
    end
  end
end
