module AePageObjects
  module SingleWindow
    class SameWindowLoaderStrategy
      def initialize(window)
        @window = window
      end

      def load_document_with_condition(condition)
        document = load_document(condition.document_class)

        if document && condition_matches?(document, condition)
          document
        else
          nil
        end
      end

      def document_not_loaded_error_message(query)
        "Current window does not contain document with type in #{query.permitted_types_dump}."
      end

    private

      def load_document(document_class)
        current_document = @window.current_document

        # preserve the existing document if it matches
        # the type we're looking for
        # TODO - add test case
        if current_document && current_document.class == document_class
          current_document
        else
          @window.load(document_class)
        end
      rescue AePageObjects::LoadingPageFailed
        nil
      end

      def condition_matches?(document, condition)
        condition.match?(document)
      rescue AePageObjects::LoadingElementFailed
        false
      end
    end
  end
end
