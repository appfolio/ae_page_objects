require 'ae_page_objects/util/hash_symbolizer'

module AePageObjects
  class Element < Node
    attr_reader :parent

    def initialize(parent, options_or_locator = {})
      @parent       = parent
      @locator      = nil
      @name         = nil

      configure(parse_options(options_or_locator))

      raise ArgumentError, ":name or :locator is required" unless @name || @locator

      @locator ||= default_locator

      super(scoped_node)
    end

    def document
      @document ||= begin
        node = self.parent

        until node.is_a?(Document)
          node = node.parent
        end

        node
      end
    end

    def browser
      @browser ||= document.browser
    end

    def window
      @window ||= document.window
    end

    def __full_name__
      if parent.respond_to?(:__full_name__)
        name_parts = [ parent.__full_name__, __name__ ].compact
        if name_parts.empty?
          nil
        else
          name_parts.join('_')
        end
      else
        __name__
      end
    end

    def full_name
      __full_name__
    end

    def __name__
      @name
    end

    def name
      __name__
    end

    def to_s
      super.tap do |str|
        str << "@name:<#{@name}>; #@locator:<#{@locator}>"
      end
    end

    def using_default_locator?
      @locator == default_locator
    end

    def reload_ancestors
      # Reload the parent first, traversing up until we hit the document
      parent.reload_ancestors if parent.respond_to?(:reload_ancestors)

      return unless @node.respond_to?(:reload)

      # Tell the capybara node to reload
      @node.reload
      ensure_loaded!
    end

  private

    def configure(options)
      @locator = options.delete(:locator)
      @name    = options.delete(:name)
      if options.key?(:wait)
        @wait = options.delete(:wait)
      else
        @wait = true
      end

      @name = @name.to_s if @name
    end

    def parse_options(options_or_locator)
      if options_or_locator.is_a?( Hash )
        HashSymbolizer.new(options_or_locator).symbolize_keys
      else
        {:locator => options_or_locator}
      end
    end

    def default_locator
      @default_locator ||= Proc.new { "##{__full_name__}" }
    end

    def scoped_node
      locator = eval_locator(@locator)

      return parent.node if locator.empty?

      default_options = { minimum: 0 }
      if locator.last.is_a?(::Hash)
        locator[-1] = default_options.merge(locator.last)
      else
        locator.push(default_options)
      end

      locator_copy = locator.dup
      options = locator_copy.pop

      if @wait
        node = AePageObjects.wait_until { parent.node.first(*locator_copy, **options) }
      else
        node = parent.node.first(*locator_copy, **options)
        raise LoadingElementFailed, 'Element Not Found' unless node
      end
      node.allow_reload!
      node
    rescue AePageObjects::WaitTimeoutError => e
      raise LoadingElementFailed, e.message
    end
  end
end
