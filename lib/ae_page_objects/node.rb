require 'ae_page_objects/core/dsl'
require 'ae_page_objects/concerns/load_ensuring'
require 'ae_page_objects/concerns/staleable'

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
        self.class.current_url
      end

      def current_url_without_params
        self.class.current_url_without_params
      end

      METHODS_TO_DELEGATE_TO_NODE = [:find, :all, :value, :set, :text, :visible?]
      METHODS_TO_DELEGATE_TO_NODE.each do |m|
        class_eval <<-RUBY
          def #{m}(*args, &block)
            node.send(:#{m}, *args, &block)
          rescue Capybara::ElementNotFound => e
            raise AePageObjects::LoadingElementFailed, e.message
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
        Capybara.current_session.current_url.sub(/^https?:\/\/[^\/]*/, '')
      end

      def current_url_without_params
        current_url.sub(/\?.*/, '')
      end
    end

    extend AePageObjects::Dsl

    include Methods
    extend  ClassMethods

    include AePageObjects::Concerns::LoadEnsuring
    include AePageObjects::Concerns::Staleable
  end
end
