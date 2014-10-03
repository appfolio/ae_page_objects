require 'timeout'

module AePageObjects
  class ElementProxy

    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord>
    instance_methods.each do |m|
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to/
        undef_method m
      end
    end

    def initialize(element_class, *args)
      @element_class = element_class
      @args          = args

      @loaded_element = nil
    end

    # Provided so that visible? can be asked without
    # an explicit check for present? first.
    def visible?
      Waiter.wait_for do
        inst = presence
        !! inst && inst.visible?
      end
    end

    def not_visible?
      Waiter.wait_for do
        inst = presence
        inst.nil? || ! inst.visible?
      end
    end

    def present?
      ! presence.nil?
    end

    def wait_for_absence
      absent = Waiter.wait_for do
        begin
          load_element

          false
        rescue LoadingElementFailed
          true
        rescue => e
          if Capybara.current_session.driver.is_a?(Capybara::Selenium::Driver) &&
             e.is_a?(Selenium::WebDriver::Error::StaleElementReferenceError)
            # ignore and spin around for another check
            false
          else
            raise
          end
        end
      end

      unless absent
        raise ElementNotAbsent, "element_class: #{@element_class}, options: #{@options.inspect}"
      end
    end

    def not_present?
      wait_for_absence
      true
    rescue ElementNotAbsent
      false
    end

    def presence
      implicit_element
    rescue AePageObjects::LoadingElementFailed
      nil
    end

    def is_a?(type)
      type == @element_class || type == ElementProxy
    end

    def kind_of?(type)
      is_a?(type)
    end

    def method_missing(name, *args, &block)
      if name == "class"
        return @element_class
      end

      implicit_element.__send__(name, *args, &block)
    end

    def respond_to?(*args)
      super || @element_class.allocate.respond_to?(*args)
    end

  private

    def load_element
      @element_class.new(*@args)
    end

    def implicit_element
      @loaded_element ||= load_element
    end
  end
end
