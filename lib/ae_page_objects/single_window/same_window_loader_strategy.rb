module AePageObjects
  module SingleWindow
    class SameWindowLoaderStrategy
      def load_document_with_condition(condition)
        document = load_document(condition.document_class)

        if document && condition_matches?(document, condition)
          document
        else
          nil
        end
      end

      def document_not_loaded_error(document_loader)
        DocumentLoadError.new("Current window does not contain document with type in #{document_loader.permitted_types_dump}.")
      end

    private

      def load_document(document_class)
        document_class.new
      rescue AePageObjects::LoadingFailed
        nil
      end

      def condition_matches?(document, condition)
        condition.match?(document)
      rescue Capybara::ElementNotFound
        false
      end
    end
  end
end
