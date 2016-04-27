module AePageObjects
  class Document < Node
    class << self
      def can_load_from_current_url?
        return true if paths.empty?

        url = current_url_without_params

        paths.any? do |path|
          site.path_recognizes_url?(path, url)
        end
      end

      private

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

      def paths
        @paths ||= []
      end

      def path(path_method)
        raise ArgumentError, "path must be a symbol or string" if ! path_method.is_a?(Symbol) && ! path_method.is_a?(String)

        paths << path_method

        extend VisitMethod
      end

      def site
        @site ||= Site.from(self)
      end
    end

    attr_reader :window

    def initialize
      super(Capybara.current_session)

      @window = browser.current_window
      @window.current_document = self
    end

    def browser
      AePageObjects.browser
    end

    def document
      self
    end

    private

    def ensure_loaded!
      unless Waiter.wait_until { self.class.can_load_from_current_url? }
        raise LoadingPageFailed, "#{self.class.name} cannot be loaded with url '#{current_url_without_params}'"
      end

      begin
        super
      rescue LoadingElementFailed => e
        raise LoadingPageFailed, e.message
      end
    end
  end
end
