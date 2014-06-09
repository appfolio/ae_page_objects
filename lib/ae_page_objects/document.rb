module AePageObjects
  class Document < Node
    module Deprecations
      def new(window = nil)
        if window
          super
        else
          AePageObjects::InternalHelpers.
            deprecation_warning("Document.new is deprecated. Use Window#load(#{self.name})")

          super(AePageObjects.browser.current_window)
        end
      end

      def can_load_from_current_url?
        AePageObjects::InternalHelpers.
          deprecation_warning("Document.can_load_from_current_url? is deprecated. Use Window#can_load_document?(#{self.name})")

        AePageObjects.browser.current_window.can_load_document?(self)
      end

      def visit(*args)
        AePageObjects::InternalHelpers.deprecation_warning("#{self.name}.visit is deprecated. Use window.visit(#{self.name})")
        AePageObjects.browser.current_window.visit(self, *args)
      end
    end
    extend Deprecations

    attr_reader :window

    def initialize(window)
      super(Capybara.current_session)

      @window = window
    end

    def document
      self
    end

    class << self
      def can_load_from_url?(url)
        paths = self.paths

        return true if paths.empty?

        paths.any? do |path|
          site.path_recognizes_url?(path, url)
        end
      end

      def generate_path(path, *args)
        site.generate_path(path, *args)
      end

    private

      def paths
        @paths ||= []
      end

      def path(path_method)
        raise ArgumentError, "path must be a symbol or string" if ! path_method.is_a?(Symbol) && ! path_method.is_a?(String)

        paths << path_method
      end

      def site
        @site ||= AePageObjects::Site.from(self)
      end
    end
  end
end
