module AePageObjects
  class Collection < Element
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

    def at(index, &block)
      if index >= size || index < 0
        nil
      else
        self.item_class.new(self, :name => index, :locator => [:xpath, "#{row_xpath}[#{index + 1}]"], &block)
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

    def all
      [].tap do |all|
        self.each { |item| all << item }
      end
    end
    
    def size
      node.all(:xpath, row_xpath).size
    end
    
    def first(&block)
      self.at(0, &block)
    end

    def last(&block)
      self.at(size - 1, &block)
    end
    
    def add_more(&block)
      append
      last(&block)
    end

    def row_xpath
      @row_xpath || ".//*[contains(@class, 'item-list')]//*[contains(@class,'row') and not(contains(@style,'display'))]"
    end
    
  protected
  
    def configure(options)
      super
      
      @row_xpath = options.delete(:row_xpath)
    end
  
    def append
      node.find('.js-add-item').click
    end
  end
end
