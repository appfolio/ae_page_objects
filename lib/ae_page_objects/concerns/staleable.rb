module AePageObjects
  module Concerns
    module Staleable

      def stale?
        !!@stale
      end

      def node
        if stale?
          raise StalePageObject, "Can't access stale page object '#{self}'"
        end

        super
      end

      def stale!
        @stale = true
      end
    end
  end
end
