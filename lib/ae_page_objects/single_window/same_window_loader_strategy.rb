module AePageObjects
  module SingleWindow
    class SameWindowLoaderStrategy
      def load_document_with_condition(condition)
        document = condition.document_class.new

        return document if condition.match?(document)

        nil
      rescue AePageObjects::LoadingFailed
        # These will happen from the new() call above.
        nil
      end

      def document_not_loaded_error(document_loader)
        DocumentLoadError.new("Current window does not contain document with type in #{document_loader.permitted_types_dump}.")
      end
    end
  end
end
