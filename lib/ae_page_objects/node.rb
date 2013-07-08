module AePageObjects
  class Node
    module Methods
      def initialize(capybara_node = Capybara.current_session)
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

      def new_subclass(&block)
        klass = Class.new(self)
        klass.class_eval(&block) if block
        klass
      end
    end

    extend Dsl

    include Methods
    extend  ClassMethods

    include Concerns::LoadEnsuring
    include Concerns::Staleable
  end
end
