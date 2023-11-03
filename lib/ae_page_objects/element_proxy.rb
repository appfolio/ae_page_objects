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
      reload_element
      @loaded_element&.visible?
    end

    def hidden?
      !visible?
    end

    def present?
      reload_element
      !@loaded_element.nil?
    end

    def absent?
      !present?
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

    def wait_until_absent(timeout = nil)
      with_reloaded_element(timeout) do
        @loaded_element.nil?
      end

    rescue AePageObjects::WaitTimeoutError
      raise ElementNotAbsent, "element_class: #{@element_class}, options: #{@options.inspect}"
    end

    def is_a?(type)
      type == @element_class || type == ElementProxy
    end

    def kind_of?(type)
      is_a?(type)
    end

    def method_missing(name, *args, **kwargs, &block)
      if name == :class
        return @element_class
      end

      implicit_element.__send__(name, *args, **kwargs, &block)
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      #
      # A StaleElementReferenceError can occur when a selenium node is referenced but is no longer attached to the DOM.
      # In this case we need to work our way up the element tree to make sure we are referencing the latest DOM nodes.
      #
      # In some cases we get this exception and cannot recover from it.  This usually occurs when code outside of
      # ae_page_objects calls capybara queries directly.  In these cases we need to raise the original exception
      #
      @retry_count ||= 0
      @retry_count += 1
      if @retry_count < 5
        implicit_element.reload_ancestors
        retry
      else
        raise
      end
    end

    def respond_to?(*args)
      super || @element_class.allocate.respond_to?(*args)
    end

    private

    def load_element(wait: true)
      args = @args.dup

      options_or_locator = args.pop
      options = if options_or_locator.is_a?(Hash)
                  options_or_locator.merge(wait: wait)
                else
                  { locator: options_or_locator, wait: wait }
                end

      args << options

      @element_class.new(*args)
    end

    def implicit_element
      @loaded_element ||= load_element
    end

    def reload_element
      @loaded_element = load_element(wait: false)
    rescue LoadingElementFailed
      @loaded_element = nil
    end

    def with_reloaded_element(timeout)
      AePageObjects.wait_until(timeout) do
        reload_element
        yield
      end
    end
  end
end
