module AePageObjects
  class PageLoader
    class SameWindow
      def load_page_with_condition(condition)
        page = condition.document_class.new

        return page if condition.match?(page)

        nil
      rescue AePageObjects::LoadingFailed
        # These will happen from the new() call above.
        nil
      end

      def page_not_loaded_error(document_class, page_loader)
        PageLoadError.new("Failed instantiating a #{document_class.name} in the current window from #{page_loader.permitted_types_dump}")
      end
    end
  end
end
