module AePageObjects
  class DocumentFinder
    class DocumentWindowScanner
      def initialize(document_class, current_window, all_windows, conditions)
        @document_class = document_class
        @current_window = current_window
        @all_windows    = all_windows
        @conditions     = conditions
      end

      def find
        # Look in the current window first unless told not to
        unless @conditions.ignore_current?
          if document = load_from_window(@current_window)
            return document
          end
        end

        # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
        # until finding a Document that can be instantiated or timing out.
        @all_windows.each do |window|
          next if window == @current_window

          if document = load_from_window(window)
            return document
          end
        end

        nil
      end

      private

      def load_from_window(window)
        window.switch_to

        inst = @document_class.new

        if @conditions.match?(inst)
          return inst
        end

        nil
      rescue AePageObjects::LoadingFailed
        # These will happen from the new() call above.
        nil
      end
    end
  end
end
