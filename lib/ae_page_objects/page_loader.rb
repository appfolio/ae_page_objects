module AePageObjects
  class PageLoader
    if WINDOWS_SUPPORTED
      autoload :CrossWindow, 'ae_page_objects/page_loader/cross_window'
    end
    autoload :SameWindow, 'ae_page_objects/page_loader/same_window'

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

    def load_page(document_class)
      matching_document_conditions = @query.conditions.select do |document_condition|
        document_condition.document_class == document_class
      end

      if matching_document_conditions.empty?
        raise PageLoadError, "#{document_class.name} not expected. Allowed types: #{permitted_types_dump}"
      end

      Waiter.wait_for do
        matching_document_conditions.each do |document_condition|
          if page = @strategy.load_page_with_condition(document_condition)
            return page
          end
        end

        nil
      end

      raise @strategy.page_not_loaded_error(document_class, self)
    end
  end
end
