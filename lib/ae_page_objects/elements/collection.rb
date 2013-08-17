module AePageObjects
  class Collection < Element
    include Enumerable

    class << self
      attr_accessor :item_class

      def default_item_locator
        @default_item_locator ||= [:xpath, ".//*"]
      end

      private
      def inherited(subclass)
        subclass.item_class = self.item_class
      end
    end

    self.item_class = Element

    def item_class
      self.class.item_class
    end

    def item_xpath
      @item_xpath ||= Capybara::Selector.normalize(*eval_locator(@item_locator)).xpaths.first
    end

    def at(index, &block)
      if index >= size || index < 0
        nil
      else
        item_at(index, &block)
      end
    end

    def [](index, &block)
      at(index, &block)
    end
    
    def each(&block)
      (0..(size - 1)).each do |index|
        yield at(index)
      end
    end

    def size
      node.all(:xpath, item_xpath).size
    end

    def last(&block)
      self.at(size - 1, &block)
    end

    def add_more(&block)
      append
      last(&block)
    end

  protected
  
    def configure(options)
      super
      
      @item_locator = options.delete(:item_locator) || self.class.default_item_locator
    end
  
    def append
      node.find('.js-add-item').click
    end

  private

    def item_at(index, &block)
      ElementProxy.new(item_class_at(index), self, :name => index, :locator => item_locator_at(index), &block)
    end

    def item_class_at(index)
      item_class
    end

    def item_locator_at(index)
      [:xpath, "#{item_xpath}[#{index + 1}]"]
    end
  end
end
