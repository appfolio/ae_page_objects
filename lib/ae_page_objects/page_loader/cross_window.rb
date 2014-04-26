module AePageObjects
  class PageLoader
    class CrossWindow

      def initialize(window_list)
        @window_list     = window_list
        @original_window = window_list.current_window

        @current_window_loader = SameWindow.new
      end

      def load_page_with_condition(condition)
        # Look in the current window first unless told not to
        unless condition.page_conditions[:ignore_current]
          @original_window.switch_to

          if document = @current_window_loader.load_page_with_condition(condition)
            return document
          end
        end

        # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
        # until finding a Document that can be instantiated or timing out.
        @window_list.opened.each do |window|
          next if window == @original_window

          window.switch_to

          if document = @current_window_loader.load_page_with_condition(condition)
            return document
          end
        end

        @original_window.switch_to

        nil
      end

      def page_not_loaded_error(page_loader)
        all_windows = @window_list.opened.map do |window|
          name = window.current_document && window.current_document.to_s || "<none>"
          {:window_handle => window.handle, :document => name }
        end

        PageLoadError.new("Couldn't find page with type in #{page_loader.permitted_types_dump} in any of the open windows: #{all_windows.inspect}")
      end
    end
  end
end
