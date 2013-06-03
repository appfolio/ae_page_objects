module AePageObjects
  module Singleton
    extend ActiveSupport::Concern

    module ClassMethods
      def instance
        @instance ||= new
      end
      
      def respond_to?(*args)
        super || instance.respond_to?(*args)
      end

      def configure(&block)
        class_eval(&block)
      end

    protected

      def method_missing(*args, &block)
        instance.send(*args, &block)
      end
    end
  end
end
