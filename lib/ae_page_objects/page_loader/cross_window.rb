module AePageObjects
  class PageLoader
    class CrossWindow < PageLoader

      def initialize(window_list, query)
        super(query)

        @window_list = window_list
        @original_window = window_list.current_window
      end

      private
      def page_not_loaded(document_class)
        @original_window.switch_to

        all_windows = @windows_list.opened_windows.map do |window|
          name = window.current_document && window.current_document.to_s || "<none>"
          {:window_handle => window.handle, :document => name }
        end

        raise PageNotFound, "Couldn't find page #{document_class.name} in any of the open windows: #{all_windows.inspect}"
      end

      def load_page_with_condition(condition)
        # Look in the current window first unless told not to
        unless condition.page_conditions[:ignore_current]
          @original_window.switch_to

          if document = condition.load_page
            return document
          end
        end

        # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
        # until finding a Document that can be instantiated or timing out.
        @window_list.opened_windows.each do |window|
          next if window == @original_window

          window.switch_to

          if document = condition.load_page
            return document
          end
        end

        nil
      end
    end
  end
end
