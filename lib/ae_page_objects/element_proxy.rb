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

    def visible?
      wait_until_visible
      true
    rescue ElementNotVisible
      false
    end

    def hidden?
      wait_until_hidden
      true
    rescue ElementNotHidden
      false
    end

    def not_visible?
      hidden?
    end

    def present?
      wait_until_present
      true
    rescue ElementNotPresent
      false
    end

    def absent?
      wait_until_absent
      true
    rescue ElementNotAbsent
      false
    end

    def not_present?
      absent?
    end

    def presence
      implicit_element
    rescue LoadingElementFailed
      nil
    end

    def wait_until_visible(timeout = nil)
      is_visible = Waiter.wait_until(timeout) do
        inst = presence
        ! inst.nil? && inst.visible?
      end

      unless is_visible
        raise ElementNotVisible, "element_class: #{@element_class}, options: #{@options.inspect}"
      end
    end

    def wait_until_hidden(timeout = nil)
      is_hidden = Waiter.wait_until(timeout) do
        inst = presence
        inst.nil? || ! inst.visible?
      end

      unless is_hidden
        raise ElementNotHidden, "element_class: #{@element_class}, options: #{@options.inspect}"
      end
    end

    def wait_until_present(timeout = nil)
      is_present = Waiter.wait_until(timeout) do
        ! presence.nil?
      end

      unless is_present
        raise ElementNotPresent, "element_class: #{@element_class}, options: #{@options.inspect}"
      end
    end

    def wait_for_presence(timeout = nil)
      wait_until_present(timeout)
    end

    def wait_until_absent(timeout = nil)
      is_absent = Waiter.wait_until(timeout) do
        check_absence
      end

      unless is_absent
        raise ElementNotAbsent, "element_class: #{@element_class}, options: #{@options.inspect}"
      end
    end

    def wait_for_absence(timeout = nil)
      wait_until_absent(timeout)
    end

    def is_a?(type)
      type == @element_class || type == ElementProxy
    end

    def kind_of?(type)
      is_a?(type)
    end

    def method_missing(name, *args, &block)
      if name.to_s == "class"
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

    def check_absence
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
end
