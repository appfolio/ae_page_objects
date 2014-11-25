module AePageObjects
  module SingleWindow
    class Browser
      attr_reader :current_window

      def initialize
        @current_window = AePageObjects::SingleWindow::Window.new
      end
    end
  end
end
