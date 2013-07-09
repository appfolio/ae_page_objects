module AePageObjects
  class Window
    class << self
      def all
        @all ||= {}
      end

      def current
        current_handle = Capybara.current_session.driver.browser.window_handle

        window = all.keys.find do |window|
          window.handle == current_handle
        end

        unless window
          window = new(current_handle)
          all[window] = window
        end

        window
      end
    end

    attr_reader :current_document, :handle

    def initialize(handle)
      @handle = handle
      @current_document = nil

      self.class.all[self] = self
    end

    def current_document=(document)
      @current_document.send(:stale!) if @current_document
      @current_document = document
    end

    def switch_to
      Capybara.current_session.driver.browser.switch_to.window(handle)
      current_document
    end

    def close
      self.current_document = nil

      Capybara.current_session.execute_script("window.close();")

      self.class.all.delete(self)
    end
  end
end