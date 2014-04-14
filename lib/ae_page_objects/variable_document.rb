module AePageObjects
  class VariableDocument

    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord>
    instance_methods.each do |m|
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to|is_a?/
        undef_method m
      end
    end

    def initialize(query)
      @query = query
    end

    def is_a?(document_class)
      super || !! as_a(document_class)
    rescue AePageObjects::Error
      false
    end

    def as_a(document_class)
      matching_document_conditions = @query.conditions.select do |document_condition|
        document_condition.document_class == document_class
      end

      if matching_document_conditions.empty?
        raise InvalidCast, "Cannot cast as #{document_class.name} from #{allowed_types_dump}"
      end

      matching_document_conditions.each do |document_condition|
        if page = document_condition.load_page
          return page
        end
      end

      raise IncorrectCast, "Failed instantiating a #{document_class.name} from #{allowed_types_dump}"
    end

  private

    def implicit_document
      @implicit_document ||= as_a(implicit_document_class)
    end

    def implicit_document_class
      @implicit_document_class ||= @query.conditions.first.document_class
    end

    def allowed_types_dump
      @allowed_types ||= @query.conditions.map(&:document_class).map(&:name).inspect
    end

    def method_missing(name, *args, &block)
      implicit_document.__send__(name, *args, &block)
    end

    def respond_to?(*args)
      super || implicit_document_class.allocate.respond_to?(*args)
    end
  end
end
