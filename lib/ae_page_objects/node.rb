module AePageObjects
  class Node
    module Methods
      def initialize(capybara_node)
        @node = capybara_node
      end

      def node
        @node
      end

      def document
        raise "Must implement!"
      end

      def current_url
        warn '[DEPRECATION WARNING]: AePageObjects::Node#current_url is deprecated. Use Node#window.url'
        window.url
      end

      def current_url_without_params
        warn '[DEPRECATION WARNING]: AePageObjects::Node#current_url_without_params is deprecated. Use Node#window.url_without_params'
        window.url_without_params
      end

      METHODS_TO_DELEGATE_TO_NODE = [:find, :all, :value, :set, :text, :visible?]
      METHODS_TO_DELEGATE_TO_NODE.each do |m|
        class_eval <<-RUBY
          def #{m}(*args, &block)
            node.send(:#{m}, *args, &block)
          rescue Capybara::ElementNotFound
            raise AePageObjects::LoadingElementFailed
          end
        RUBY
      end

    private

      def eval_locator(locator)
        return [] unless locator

        if locator.respond_to?(:call)
          locator = instance_eval(&locator)
        end

        locator.is_a?(Array) ? locator : [locator.to_s]
      end
    end

    module ClassMethods
      def current_url
        warn "[DEPRECATION WARNING]: AePageObjects::Node.current_url is deprecated. Use Node#window.url"
        AePageObjects.browser.current_window.url
      end

      def current_url_without_params
        warn "[DEPRECATION WARNING]: AePageObjects::Node.current_url_without_params is deprecated. Use Node#window.url_without_params"
        AePageObjects.browser.current_window.url_without_params
      end
    end

    extend Dsl

    include Methods
    extend  ClassMethods

    include Concerns::LoadEnsuring
    include Concerns::Staleable
  end
end
