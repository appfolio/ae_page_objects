module AePageObjects
  class Collection < Element
    include Enumerable

    attr_reader :item_locator

    class << self
      attr_accessor :item_class

      private
      def inherited(subclass)
        subclass.item_class = self.item_class
      end
    end

    self.item_class = Element

    def item_class
      self.class.item_class
    end


    def at(index)
      if index >= size || index < 0
        nil
      else
        item_at(index)
      end
    end

    def [](index)
      at(index)
    end
    
    def each
      (0..(size - 1)).each do |index|
        yield at(index)
      end
    end

    def size
      node.all(:xpath, item_xpath).size
    end

    def last
      self.at(size - 1)
    end

  private
  
    def configure(options)
      super
      
      @item_locator = options.delete(:item_locator) || default_item_locator
    end

    def item_at(index)
      ElementProxy.new(item_class_at(index), self, :name => index, :locator => item_locator_at(index))
    end

    def item_class_at(index)
      item_class
    end

    def item_xpath
      @item_xpath ||= Capybara::Selector.normalize(*eval_locator(@item_locator)).xpaths.first
    end

    def item_locator_at(index)
      [:xpath, "#{item_xpath}[#{index + 1}]"]
    end

    def default_item_locator
      @default_item_locator ||= [:xpath, ".//*"]
    end
  end
end
