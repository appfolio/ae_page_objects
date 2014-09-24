module AePageObjects
  class DocumentQuery
    class Condition
      attr_reader :document_class, :document_conditions

      def initialize(document_class, document_conditions = {}, &block_condition)
        @document_class    = document_class

        @document_conditions = document_conditions || {}
        @document_conditions[:block] = block_condition if block_condition
      end

      def match?(document)
        @document_conditions.each do |type, value|
          case type
          when :title then
            return false unless Capybara.current_session.driver.browser.title.include?(value)
          when :url then
            return false unless document.current_url.include?(value)
          when :block then
            return false unless value.call(document)
          end
        end

        true
      end
    end

    attr_reader :conditions

    def initialize(*document_classes, &block)
      @conditions = []

      if document_classes.empty?
        raise ArgumentError, "block expected" if block.nil?
        block.call(self)

        raise ArgumentError, "conditions expected" if @conditions.empty?
      else

        all_documents = document_classes.all? do |document_class|
          document_class.is_a?(Class) && document_class < Document
        end

        if all_documents
          if document_classes.size == 1
            matches(document_classes.first, {}, &block)
          else
            raise ArgumentError, "block unexpected for multiple documents" unless block.nil?

            document_classes.each do |document_class|
              matches(document_class)
            end
          end
        else
          raise ArgumentError, "Expected (Document, document_options)" unless document_classes.size == 2
          raise ArgumentError, "Expected (Document, document_options)" unless (document_classes.first < Document) && document_classes.last.is_a?(Hash)

          matches(document_classes.first, document_classes.last, &block)
        end
      end
    end

    def matches(document_class, conditions = {}, &block_condition)
      @conditions << Condition.new(document_class, conditions, &block_condition)
    end

    def default_document_class
      conditions.first.document_class
    end

    def permitted_types_dump
      conditions.map(&:document_class).map(&:name).inspect
    end
  end
end
