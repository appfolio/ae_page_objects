module AePageObjects
  class DocumentFinder
    class DocumentWindowScanner
      def initialize(document_class, start_window, all_windows, conditions)
        @document_class = document_class
        @start_window   = start_window
        @all_windows    = all_windows
        @conditions     = conditions
      end

      def find
        if document = load_from_window(@start_window, is_current = true)
          return document
        end

        @all_windows.each do |window|
          next if window == @start_window

          if document = load_from_window(window, is_current = false)
            return document
          end
        end

        nil
      end

      private

      def load_from_window(window, is_current)
        window.switch_to

        inst = @document_class.new

        if @conditions.match?(inst, is_current)
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
