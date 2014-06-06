module AePageObjects
  class DocumentLoader
    def initialize(query, strategy)
      @query    = query
      @strategy = strategy
    end

    def default_document_class
      @default_document_class ||= @query.conditions.first.document_class
    end

    def permitted_types_dump
      @permitted_types_dump ||= @query.conditions.map(&:document_class).map(&:name).inspect
    end

    def load
      Waiter.wait_for do
        @query.conditions.each do |document_condition|
          if document = @strategy.load_document_with_condition(document_condition)
            return document
          end
        end

        nil
      end

      raise @strategy.document_not_loaded_error(self)
    end
  end
end
