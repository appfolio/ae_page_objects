require 'ae_page_objects/util/page_polling'

module AePageObjects
  class DocumentLoader
    include AePageObjects::PagePolling

    def initialize(query, strategy)
      @query    = query
      @strategy = strategy
    end

    def load
      begin
        poll_until do
          @query.conditions.each do |document_condition|
            begin
              if document = @strategy.load_document_with_condition(document_condition)
                return document
              end
            rescue => e
              raise unless catch_poll_util_error?(e)
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
