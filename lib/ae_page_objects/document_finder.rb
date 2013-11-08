module AePageObjects
  class DocumentFinder

    def initialize(document_class)
      @document_class = document_class
    end

    class Conditions
      def initialize(conditions, block_condition)
        @conditions = conditions || {}
        @conditions[:block] = block_condition if block_condition
      end

      def match?(page)
        @conditions.each do |type, value|
          case type
          when :title then
            return false unless browser.title.include?(value)
          when :url then
            return false unless page.current_url.include?(value)
          when :block then
            return false unless value.call(page)
          end
        end

        true
      end
    end

    def find(conditions = {}, &extra_condition)
      original_window = AePageObjects::Window.current

      # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
      # until finding a Document that can be instantiated or timing out.
      Capybara.wait_until do
        find_window(Conditions.new(conditions, extra_condition))
      end

    rescue Capybara::TimeoutError
      original_window.switch_to

      all_windows = AePageObjects::Window.all.map do |window|
        name = window.current_document && window.current_document.to_s || "<none>"
        {:window_handle => window.handle, :document => name }
      end

      raise PageNotFound, "Couldn't find page #{@document_class.name} in any of the open windows: #{all_windows.inspect}"
    end

  private

    def find_window(conditions)
      AePageObjects::Window.all.each do |window|
        window.switch_to

        if inst = attempt_to_load(conditions)
          return inst
        end
      end

      nil
    end

    def attempt_to_load(conditions)
      inst = @document_class.new

      if conditions.match?(inst)
        return inst
      end

      nil
    rescue AePageObjects::LoadingFailed
      # These will happen from the new() call above.
      nil
    end
  end
end
