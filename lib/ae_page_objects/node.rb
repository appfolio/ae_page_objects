require 'ae_page_objects/core/dsl'
require 'ae_page_objects/element_proxy'

module AePageObjects
  class Node
    extend Dsl

    class << self
      def current_url
        Capybara.current_session.current_url.sub(/^https?:\/\/[^\/]*/, '')
      end

      def current_url_without_params
        current_url.sub(/(\?|\#).*/, '')
      end
    end

    is_loaded do
      if locator = loaded_locator
        default_options = { minimum: 0 }
        if locator.last.is_a?(::Hash)
          locator[-1] = default_options.merge(locator.last)
        else
          locator.push(default_options)
        end

        node.first(*eval_locator(locator)) != nil
      else
        true
      end
    end

    def initialize(capybara_node)
      @node  = capybara_node
      @stale = false

      ensure_loaded!
    end

    def node
      if stale?
        raise StalePageObject, "Can't access stale page object '#{self}'"
      end

      @node
    end

    def stale?
      @stale
    end

    def stale!
      @stale = true
    end

    def document
      raise "Must implement!"
    end

    def current_url
      self.class.current_url
    end

    def current_url_without_params
      self.class.current_url_without_params
    end

    METHODS_TO_DELEGATE_TO_NODE = [:value, :set, :text, :visible?]
    METHODS_TO_DELEGATE_TO_NODE.each do |m|
      class_eval <<-RUBY
        def #{m}(*args, &block)
          node.send(:#{m}, *args, &block)
        rescue Capybara::ElementNotFound => e
          raise LoadingElementFailed, e.message
        end
      RUBY
    end

    def element(options_or_locator)
      options = if options_or_locator.is_a?(Hash)
                  options_or_locator.dup
                else
                  {:locator => options_or_locator}
                end

      element_class = options.delete(:is) || Element

      ElementProxy.new(element_class, self, options)
    end

    private

    def eval_locator(locator)
      return [] unless locator

      if locator.respond_to?(:call)
        locator = instance_eval(&locator)
      end

      locator.is_a?(Array) ? locator : [locator.to_s]
    end

    def loaded_locator
    end

    def ensure_loaded!
      AePageObjects.wait_until { is_loaded? }
    rescue AePageObjects::WaitTimeoutError => e
      raise LoadingElementFailed, e.message
    end

    # This should not block and instead attempt to return immediately (e.g. use #all / #first
    # instead of #find / #has_selector ). Unfortunately, this is difficult to enforce since even
    # with #all / #first capyabara may wait.
    def is_loaded?
      self.class.is_loaded_blocks.all? { |block| self.instance_eval(&block) }
    end
  end
end
