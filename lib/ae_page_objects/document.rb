module AePageObjects
  class Document < Node
    include Concerns::Visitable

    class << self

      def find(&extra_condition)
        original_window = AePageObjects::Window.current

        # Loop through all the windows and attempt to instantiate the Document. Continue to loop around
        # until finding a Document that can be instantiated or timing out.
        Capybara.wait_until do
          find_window(&extra_condition)
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

      def find_window(&extra_condition)
        AePageObjects::Window.all.each do |window|
          window.switch_to

          if inst = attempt_to_load(&extra_condition)
            return inst
          end
        end

        nil
      end

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

      def site
        @site ||= AePageObjects::Site.from(self)
      end
    end

    attr_reader :window
    
    def initialize
      super(Capybara.current_session)

      @window = Window.current
      @window.current_document = self
    end
    
    def document
      self
    end
  end
end