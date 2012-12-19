module AePageObjects
  class Element < Node
    attr_reader :parent, :default_name
    
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
    
    def dom_id
      if parent.respond_to?(:dom_id)
        "#{parent.dom_id}_#{__name__}"
      else
        __name__
      end
    end
    
    def __name__
      @name || default_name
    end
    
    alias_method :name, :__name__
    
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
      @default_locator ||= Proc.new { "##{dom_id}" }
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
