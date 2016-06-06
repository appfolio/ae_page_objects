require 'ae_page_objects/single_window/window'

module AePageObjects
  module SingleWindow
    class Browser
      attr_reader :current_window

      def initialize
        @current_window = Window.new
      end
    end
  end
end
