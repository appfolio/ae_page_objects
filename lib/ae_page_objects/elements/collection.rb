require 'ae_page_objects/element_proxy'

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
      size.times do |index|
        yield item_at(index)
      end
    end

    def size
      node.all(:xpath, item_xpath, options).size
    end

    def last
      self.at(size - 1)
    end

  private

    def configure(options)
      super

      @item_locator = options.delete(:item_locator) || default_item_locator
    end

    def options
      evaled_locator = eval_locator(@item_locator)
      evaled_locator.last.is_a?(::Hash) ? evaled_locator.last.dup : {}
    end

    def item_at(index)
      element(is: item_class_at(index), name: index, locator: item_locator_at(index))
    end

    def item_class_at(index)
      item_class
    end

    def item_xpath
      @item_xpath ||= begin
        query_args = eval_locator(@item_locator).dup

        if query_args.first.to_sym == :xpath
          #
          # Use the { exact: true } setting for XPath selectors that use "XPath.is".  For example, given the XPath
          #   XPath::HTML.descendant(:div)[XPath.text.is('Example Text')]
          # the resulting path will be
          #   .//div[./text() = 'Example Text']
          # instead of
          #   .//div[contains(./text(), 'Example Text')]
          # See https://github.com/jnicklas/capybara#exactness for more information.
          #
          default_options = {:exact => true}
          if query_args.last.is_a?(::Hash)
            query_args[-1] = default_options.merge(query_args.last)
          else
            query_args.push(default_options)
          end
        end

        query = Capybara::Query.new(*query_args)

        result = query.xpath

        # if it's CSS, we need to run it through XPath as Capybara::Query#xpath only
        # works when the selector is xpath. Lame.
        if query.selector.format == :css
          result = XPath.css(query.xpath).to_xpath
        end

        result
      end
    end

    def item_locator_at(index)
      [:xpath, "#{item_xpath}[#{index + 1}]", options]
    end

    def default_item_locator
      @default_item_locator ||= [:xpath, ".//*"]
    end
  end
end
