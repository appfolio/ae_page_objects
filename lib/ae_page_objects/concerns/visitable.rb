module AePageObjects
  module Concerns
    module Visitable

      def self.included(target)
        target.extend ClassMethods
      end

    private

      def ensure_loaded!
        begin
          AePageObjects.wait_until { self.class.can_load_from_current_url? }
        rescue WaitTimeoutError
          raise LoadingPageFailed, "#{self.class.name} cannot be loaded with url '#{current_url_without_params}'"
        end

        begin
          super
        rescue LoadingElementFailed => e
          raise LoadingPageFailed, e.message
        end
      end

      module VisitMethod
        def visit(*args)
          args = args.dup
          inner_options = args.last.is_a?(::Hash)? args.last : {}

          path = inner_options.delete(:via) || paths.first

          full_path = site.generate_path(path, *args)
          raise PathNotResolvable, "#{self.name} not visitable via #{paths.first}(#{args.inspect})" unless full_path

          Capybara.current_session.visit(full_path)
          new
        end
      end

      module ClassMethods

        def can_load_from_current_url?
          return true if paths.empty?

          url = current_url_without_params

          paths.any? do |path|
            site.path_recognizes_url?(path, url)
          end
        end

      private

        def paths
          @paths ||= []
        end

        def path(path_method)
          raise ArgumentError, "path must be a symbol or string" if ! path_method.is_a?(Symbol) && ! path_method.is_a?(String)

          paths << path_method

          extend VisitMethod
        end
      end
    end
  end
end
