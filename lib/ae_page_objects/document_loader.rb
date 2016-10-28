module AePageObjects
  class DocumentLoader
    def initialize(query, strategy)
      @query    = query
      @strategy = strategy
    end

    def load
      begin
        AePageObjects.wait_until do
          @query.conditions.each do |document_condition|
            if document = @strategy.load_document_with_condition(document_condition)
              return document
            end
          end

          nil
        end
      rescue AePageObjects::WaitTimeoutError
      end

      raise DocumentLoadError, @strategy.document_not_loaded_error_message(@query)
    end
  end
end
