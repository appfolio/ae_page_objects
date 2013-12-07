module AePageObjects
  class DocumentFinder

    class Conditions
      def initialize(conditions, block_condition)
        @conditions = conditions || {}
        @conditions[:block] = block_condition if block_condition
      end

      def match?(page, is_current)
        @conditions.each do |type, value|
          case type
          when :title then
            return false unless Capybara.current_session.driver.browser.title.include?(value)
          when :url then
            return false unless page.current_url.include?(value)
          when :block then
            return false unless value.call(page)
          when :ignore_current
            return false if is_current && value
          end
        end

        true
      end
    end

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

    def initialize(document_class)
      @document_class  = document_class
      @original_window = AePageObjects::Window.current
    end

    def find(conditions = {}, &extra_condition)
      # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
      # until finding a Document that can be instantiated or timing out.
      conditions = Conditions.new(conditions, extra_condition)

      Capybara.wait_until do
        DocumentWindowScanner.new(@document_class, @original_window, AePageObjects::Window.all, conditions).find
      end

    rescue Capybara::TimeoutError
      @original_window.switch_to

      all_windows = AePageObjects::Window.all.map do |window|
        name = window.current_document && window.current_document.to_s || "<none>"
        {:window_handle => window.handle, :document => name }
      end

      raise PageNotFound, "Couldn't find page #{@document_class.name} in any of the open windows: #{all_windows.inspect}"
    end
  end
end
