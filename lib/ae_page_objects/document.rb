module AePageObjects
  class Document < Node
    attr_reader :window

    def initialize
      # TODO - this bad: the base class references this, so it should initialize it
      @window = browser.current_window

      super(Capybara.current_session)

      @window.current_document = self
    end

    def document
      self
    end

    class << self
      def can_load_in_window?(window)
        paths = self.paths

        return true if paths.empty?

        url = window.url_without_params

        paths.any? do |path|
          site.path_recognizes_url?(path, url)
        end
      end

      def can_load_from_current_url?
        can_load_in_window?(AePageObjects.browser.current_window)
      end

      def paths
        @paths ||= []
      end

      def path(path_method)
        raise ArgumentError, "path must be a symbol or string" if ! path_method.is_a?(Symbol) && ! path_method.is_a?(String)

        paths << path_method

        extend VisitMethod
      end

    private

      module VisitMethod
        def visit(*args)
          raise ArgumentError, "Cannot pass block to visit()" if block_given?

          full_path = site.generate_path(paths.first, *args)
          raise PathNotResolvable, "#{self.name} not visitable via #{paths.first}(#{args.inspect})" unless full_path

          Capybara.current_session.visit(full_path)
          new
        end
      end

      def site
        @site ||= AePageObjects::Site.from(self)
      end
    end

  private

    def browser
      AePageObjects.browser
    end

    def ensure_loaded!
      unless Waiter.wait_for { self.class.can_load_in_window?(self.window) }
        raise LoadingPageFailed, "#{self.class.name} cannot be loaded with url '#{window.url_without_params}'"
      end

      begin
        super
      rescue LoadingElementFailed => e
        raise LoadingPageFailed, e.message
      end
    end
  end
end
