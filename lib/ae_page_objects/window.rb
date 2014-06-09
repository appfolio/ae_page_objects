module AePageObjects
  class Window
    module Deprecations
      def all
        AePageObjects::InternalHelpers.deprecation_warning("Window.all is deprecated. Use AePageObjects.browser.windows()")
        AePageObjects.browser.windows
      end

      def close_all
        AePageObjects::InternalHelpers.deprecation_warning("Window.close_all is deprecated. Use AePageObjects.browser.windows.close_all()")
        all.close_all
      end
    end
    extend Deprecations

    attr_reader :browser, :current_document

    def initialize(browser)
      @browser          = browser
      @current_document = nil
    end

    def url
      # TODO - Is Capybara.current_session the right thing to use here?
      Capybara.current_session.current_url.sub(/^https?:\/\/[^\/]*/, '')
    end

    def url_without_params
      url.sub(/\?.*/, '')
    end

    def can_load_document?(document_class)
      document_class.can_load_from_url?(url_without_params)
    end

    def load(document_class)
      unless Waiter.wait_for { can_load_document?(document_class) }
        raise LoadingPageFailed, "#{document_class.name} cannot be loaded with url '#{url_without_params}'"
      end

      document = nil

      begin
        document = document_class.new(self)
      rescue LoadingElementFailed => e
        raise LoadingPageFailed, e.message
      end

      assign_current_document(document)
    end

    class PathResolver
      def initialize(document_class, options)
        @document_class = document_class
        @options = options
      end

      def resolve
        path = options.delete(:path)
        path ||= @document_class.paths.first

        generated_path = @document_class.generate_path(path, options)

        unless generated_path
          raise PathNotResolvable, "#{@document_class.name} not visitable via #{path.first}(#{@options.inspect})"
        end
      end
    end

    def visit(document_class, options = {})
      path_resolver = PathResolver.new(document_class, options)

      Capybara.current_session.visit(path_resolver.path)

      load(document_class)
    end

    def change_to(*document_classes, &block)
      query           = DocumentQuery.new(*document_classes, &block)
      document_loader = DocumentLoader.new(query, SameWindowLoaderStrategy.new(self))
      loaded_page     = document_loader.load

      DocumentProxy.new(loaded_page, query)
    end

  private

    def assign_current_document(document)
      @current_document.send(:stale!) if @current_document
      @current_document = document
    end
  end
end
