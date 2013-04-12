module AePageObjects
  class ElementProxy
    
    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord> 
    instance_methods.each do |m| 
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to/
        undef_method m 
      end
    end
    
    def initialize(element_class, *args, &block)
      @element_class = element_class
      @args          = args
      @block         = block
      
      # Yield to the block immediately by creating 
      # the element. Block use assumes presence. Since
      # the underlying element is passed when yielding
      # the block level variable won't have access to
      # the proxy methods, but that's ok.
      if block_given?
        element
      end
    end
    
    # Provided so that visible? can be asked without
    # an explicit check for present? first.
    def visible?
      !!presence.try(:visible?)
    end
    
    def not_visible?
      Capybara.current_session.wait_until do
        Capybara.using_wait_time(0) do
          ! visible?
        end
      end
    rescue Capybara::TimeoutError
      false  
    end

    def present?
      presence.present?
    end
    
    def not_present?(timeout = 0)
      Capybara.using_wait_time(timeout) do
        ! present?
      end
    end
    
    def presence
      element
    rescue Capybara::ElementNotFound
      nil
    end
    
    def is_a?(type)
      type == @element_class || type == ElementProxy
    end
    alias_method :kind_of?, :is_a?
            
    def method_missing(name, *args, &block)
      if name == "class"
        return @element_class
      end
      
      element.__send__(name, *args, &block)
    end
    
    def respond_to?(*args)
      super || @element_class.allocate.respond_to?(*args)
    end
    
  private
  
    def element
      @element ||= @element_class.new(*@args, &@block)
    end
  end
end
