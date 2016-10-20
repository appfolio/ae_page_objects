require 'ae_page_objects/core/dsl'

module AePageObjects
  class Node
    extend Dsl
    extend Forwardable
    include InternalHelpers

    class << self
      def current_url
        Capybara.current_session.current_url.sub(/^https?:\/\/[^\/]*/, '')
      end

      def current_url_without_params
        current_url.sub(/(\?|\#).*/, '')
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

    METHODS_TO_DELEGATE_TO_NODE = [:value, :set, :text, :visible?]
    def_delegators :node, *METHODS_TO_DELEGATE_TO_NODE

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
      AePageObjects.wait_until { is_loaded? } and return

      raise LoadingElementFailed
    rescue AePageObjects::WaitTimeOut => e
      raise LoadingElementFailed, e.message
    end

    def is_loaded?
      if locator = loaded_locator
        args = eval_locator(locator)
        options = extract_options!(args).merge(minimum: 0)
        node.has_selector?(*(args + [options]))
      else
        true
      end
    end
  end
end
