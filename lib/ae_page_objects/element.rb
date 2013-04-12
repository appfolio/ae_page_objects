module AePageObjects
  class Element < Node
    attr_reader :parent, :default_name
    
    class << self
      def new(*args)
        super(*args).tap do |me|
          yield me if block_given?
        end
      end
    end
    
    def initialize(parent, name, options_or_locator = {})
      @parent       = parent
      @default_name = name.to_s
      @locator      = nil
      @name         = nil
      
      configure(parse_options(options_or_locator))
      
      @locator ||= default_locator
      
      super(scoped_node)
    end
    
    def document
      @document ||= begin
        node = self.parent
        
        until node.is_a?(::AePageObjects::Document)
          node = node.parent
        end
        
        node
      end
    end
    
    def __full_name__
      if parent.respond_to?(:__full_name__)
        "#{parent.__full_name__}_#{__name__}"
      else
        __name__
      end
    end

    def full_name
      __full_name__
    end

    def __name__
      @name || default_name
    end

    def name
      __name__
    end
    
    def to_s
      super.tap do |str|
        str << "#name:<#{__name__}>"
      end
    end
    
    def using_default_locator?
      @locator == default_locator
    end
    
  private
  
    def configure(options)
      @locator = options.delete(:locator)
      @name    = options.delete(:name).try(:to_s)
    end
  
    def parse_options(options_or_locator)
      if options_or_locator.is_a?( Hash )
        options_or_locator.symbolize_keys
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
        if locator.present?
          return parent.find(*locator)
        end
      end
      
      parent.node
    end
  end
end
