module AePageObjects
  class PageLoader
    if WINDOWS_SUPPORTED
      autoload :CrossWindow, 'ae_page_objects/page_loader/cross_window'
    end
    autoload :SameWindow, 'ae_page_objects/page_loader/same_window'

    def initialize(query)
      @query = query
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
        raise PageNotExpected, document_class.name
      end

      Waiter.wait_for do
        matching_document_conditions.each do |document_condition|
          if page = load_page_with_condition(document_condition)
            return page
          end
        end
      end

      page_not_loaded(document_class)
    end

  private
    def page_not_loaded(document_class)
      raise "must implement"
    end

    def load_page_with_condition(condition)
      raise "must implement"
    end
  end
end
