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

    def not_present?
      Waiter.wait_for do
        ! present?
      end
    end

    def presence
      element
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

      element.__send__(name, *args, &block)
    end

    def respond_to?(*args)
      super || @element_class.allocate.respond_to?(*args)
    end

  private

    def element
      @element ||= @element_class.new(*@args)
    end
  end
end
