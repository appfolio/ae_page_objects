module AePageObjects
  class Document < Node
    include Concerns::Visitable

    class << self

      def find(&extra_condition)
        original_window = AePageObjects::Window.current

        # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
        # until finding a Document that can be instantiated or timing out.
        Capybara.wait_until do
          AePageObjects::Window.all.each do |window|
            window.switch_to

            if inst = attempt_to_load(&extra_condition)
              break inst
            end
          end
        end

      rescue Capybara::TimeoutError
        original_window.switch_to

        all_windows = AePageObjects::Window.all.map do |window|
          {:window_handle => window.handle, :document => window.current_document.try(:name) }
        end

        raise PageNotFound, "Couldn't find page #{self.name} in any of the open windows: #{all_windows.inspect}"
      end

    private
      def attempt_to_load(&extra_condition)
        inst = new

        if extra_condition.nil? || inst.instance_eval(&extra_condition)
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