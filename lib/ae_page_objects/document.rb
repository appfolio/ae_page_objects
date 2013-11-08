module AePageObjects
  class Document < Node
    include Concerns::Visitable

    class FindConditions
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

    class << self

      def find(conditions = {}, &extra_condition)
        original_window = AePageObjects::Window.current

        # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
        # until finding a Document that can be instantiated or timing out.
        Capybara.wait_until do
          find_window(FindConditions.new(conditions, extra_condition))
        end

      rescue Capybara::TimeoutError
        original_window.switch_to

        all_windows = AePageObjects::Window.all.map do |window|
          name = window.current_document && window.current_document.to_s || "<none>"
          {:window_handle => window.handle, :document => name }
        end

        raise PageNotFound, "Couldn't find page #{self.name} in any of the open windows: #{all_windows.inspect}"
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
        inst = new

        if conditions.match?(inst)
          return inst
        end

        nil
      rescue AePageObjects::LoadingFailed
        # These will happen from the new() call above.
        nil
      end
    end

    attr_reader :window
    
    def initialize
      super(Capybara.current_session)
    end

    if defined? Selenium::WebDriver
      attr_reader :window
    
      def initialize
        super(Capybara.current_session)

        @window = Window.current
        @window.current_document = self
      end
    end
    
    def document
      self
    end
    
    class << self
    private
      def site
        @site ||= AePageObjects::Site.from(self)
      end
    end
  end
end
