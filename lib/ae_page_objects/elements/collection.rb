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
      #
      # In some cases when #size is called while the DOM is updating, Capybara
      # will catch (and swallow) underlying exceptions such as
      # `Selenium::WebDriver::Error::StaleElementReferenceError`.
      # When this happens it will wait up to the max wait time, which can cause
      # issues for `AePageObjects.wait_until` blocks.
      #
      # To prevent this issue the #all and #size calls are made with the Capybara
      # wait time set to 0.
      #
      Capybara.using_wait_time(0) do
        node.all(:xpath, item_xpath, options).size
      end
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

        default_options = {
          session_options: Capybara.session_options
        }

        if query_args[1].is_a?(XPath::Expression)
          #
          # Use the { exact: true } setting for XPath selectors that use "XPath.is".  For example, given the XPath
          #   XPath.descendant(:div)[XPath.text.is('Example Text')]
          # the resulting path will be
          #   .//div[./text() = 'Example Text']
          # instead of
          #   .//div[contains(./text(), 'Example Text')]
          # See https://github.com/jnicklas/capybara#exactness for more information.
          #
          default_options[:exact] = true
        end

        if query_args.last.is_a?(::Hash)
          query_args[-1] = default_options.merge(query_args.last)
        else
          query_args.push(default_options)
        end

        query = Capybara::Queries::SelectorQuery.new(*query_args)

        result = query.xpath

        # if it's CSS, we need to run it through XPath as Capybara::Queries::SelectorQuery#xpath only
        # works when the selector is xpath. Lame.
        if query.selector.format == :css
          result = XPath.css(query.xpath).to_xpath
        end

        result
      end
    end

    def item_locator_at(index)
      [:xpath, "(#{item_xpath})[#{index + 1}]", options]
    end

    def default_item_locator
      @default_item_locator ||= [:xpath, ".//*"]
    end
  end
end
