require 'ae_page_objects/node'

module AePageObjects
  class Element < AePageObjects::Node
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

        until node.is_a?(AePageObjects::Document)
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

  private

    def configure(options)
      @locator = options.delete(:locator)
      @name    = options.delete(:name)

      @name = @name.to_s if @name
    end

    def parse_options(options_or_locator)
      if options_or_locator.is_a?( Hash )
        AePageObjects::HashSymbolizer.new(options_or_locator).symbolize_keys
      else
        {:locator => options_or_locator}
      end
    end

    def default_locator
      @default_locator ||= Proc.new { "##{__full_name__}" }
    end

    def scoped_node
      if @locator
        locator = eval_locator(@locator)
        if ! locator.empty?
          return parent.node.find(*locator)
        end
      end

      parent.node
    rescue Capybara::ElementNotFound => e
      raise AePageObjects::LoadingElementFailed, e.message
    end
  end
end
