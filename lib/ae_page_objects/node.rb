module AePageObjects
  class Node
    module Methods
      extend ActiveSupport::Concern

      include Dsl::Element
      include Dsl::Collection
      include Dsl::FormFor

      def initialize(capybara_node)
        @node = capybara_node
      end

      def node
        @node
      end

      def document
        raise "Must implement!"
      end

      delegate :current_url, :to => 'self.class'
      delegate :current_url_without_params, :to => 'self.class'

      delegate :find,     :to => :node
      delegate :all,      :to => :node
      delegate :value,    :to => :node
      delegate :set,      :to => :node
      delegate :text,     :to => :node
      delegate :visible?, :to => :node

    private

      def eval_locator(locator)
        return unless locator

        if locator.respond_to?(:call)
          locator = instance_eval(&locator)
        end

        locator.is_a?(Array) ? locator : [locator.to_s]
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
    end
    
    include Methods
    include Concerns::LoadEnsuring
    include Concerns::Staleable
  end
end
