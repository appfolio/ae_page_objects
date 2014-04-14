module AePageObjects
  class DocumentQuery
    class DocumentCondition
      attr_reader :document_class

      def initialize(document_class, finder_conditions)
        @document_class    = document_class
        @finder_conditions = finder_conditions
      end

      def load_page
        page = @document_class.new

        if @finder_conditions.match?(page)
          page
        else
          nil
        end
      rescue AePageObjects::LoadingFailed
        # These will happen from the new() call above.
        nil
      end
    end

    def initialize(*document_classes)
      @conditions = []

      if block_given?
        yield self
      else
        document_classes.each do |document_class|
          matches(document_class)
        end
      end
    end

    def matches(document_class, conditions = {}, &block_condition)
      @conditions << DocumentCondition.new(document_class, DocumentFinder::Conditions.from(conditions, &block_condition))
    end

    def conditions
      @conditions
    end
  end
end
