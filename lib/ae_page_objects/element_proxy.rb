require 'ae_page_objects/util/page_polling'

module AePageObjects
  class ElementProxy
    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord>
    instance_methods.each do |m|
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to/
        undef_method m
      end
    end

    include AePageObjects::PagePolling

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
      warn "[DEPRECATION WARNING]: AePageObjects::Element#not_visible? is deprecated and will be removed in version 2.0.0. Use AePageObjects::Element#hidden? instead."
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
      warn "[DEPRECATION WARNING]: AePageObjects::Element#not_present? is deprecated and will be removed in version 2.0.0. Use AePageObjects::Element#absent? instead."
      absent?
    end

    def presence
      implicit_element
    rescue LoadingElementFailed
      nil
    end

    def wait_until_visible(timeout = nil)
      with_reloaded_element(timeout) do
        !@loaded_element.nil? && @loaded_element.visible?
      end

    rescue AePageObjects::WaitTimeoutError
      raise ElementNotVisible, "element_class: #{@element_class}, options: #{@options.inspect}"
    end

    def wait_until_hidden(timeout = nil)
      with_reloaded_element(timeout) do
        @loaded_element.nil? || !@loaded_element.visible?
      end

    rescue AePageObjects::WaitTimeoutError
      raise ElementNotHidden, "element_class: #{@element_class}, options: #{@options.inspect}"
    end

    def wait_until_present(timeout = nil)
      with_reloaded_element(timeout) do
        !@loaded_element.nil?
      end

    rescue AePageObjects::WaitTimeoutError
      raise ElementNotPresent, "element_class: #{@element_class}, options: #{@options.inspect}"
    end

    def wait_for_presence(timeout = nil)
      warn "[DEPRECATION WARNING]: AePageObjects::Element#wait_for_presence is deprecated and will be removed in version 2.0.0. Use AePageObjects::Element#wait_until_present instead."
      wait_until_present(timeout)
    end

    def wait_until_absent(timeout = nil)
      with_reloaded_element(timeout) do
        @loaded_element.nil?
      end

    rescue AePageObjects::WaitTimeoutError
      raise ElementNotAbsent, "element_class: #{@element_class}, options: #{@options.inspect}"
    end

    def wait_for_absence(timeout = nil)
      warn "[DEPRECATION WARNING]: AePageObjects::Element#wait_for_absence is deprecated and will be removed in version 2.0.0. Use AePageObjects::Element#wait_until_absent instead."
      wait_until_absent(timeout)
    end

    def is_a?(type)
      type == @element_class || type == ElementProxy
    end

    def kind_of?(type)
      is_a?(type)
    end

    def method_missing(name, *args, &block)
      if name == :class
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

    def reload_element
      @loaded_element = load_element

      true
    rescue LoadingElementFailed
      @loaded_element = nil

      true
    rescue => e
      if Capybara.current_session.driver.is_a?(Capybara::Selenium::Driver) &&
        e.is_a?(Selenium::WebDriver::Error::StaleElementReferenceError)

        # Inconclusive. Leave the handling up to the caller
        false
      else
        raise
      end
    end

    def with_reloaded_element(timeout)
      poll_until(timeout) do
        reload_conclusive = reload_element
        reload_conclusive && yield
      end
    end
  end
end
