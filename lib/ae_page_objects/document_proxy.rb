module AePageObjects
  class DocumentProxy

    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord>
    instance_methods.each do |m|
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to|is_a?|instance_variable_get/
        undef_method m
      end
    end

    def initialize(loaded_page, query)
      @loaded_page = loaded_page
      @query = query
    end

    def is_a?(document_class)
       super || @loaded_page.is_a?(document_class)
    end

    def as_a(document_class)
      if @loaded_page.is_a?(document_class)
        return @loaded_page
      end

      raise CastError, "Loaded page is not a #{document_class.name}. Allowed pages: #{@query.permitted_types_dump}"
    end

  private

    def implicit_document
      if @loaded_page.is_a? @query.default_document_class
        @loaded_page
      else
        raise CastError, "#{@query.default_document_class} expected, but #{@loaded_page.class} loaded"
      end
    end

    def method_missing(name, *args, &block)
      implicit_document.__send__(name, *args, &block)
    end

    def respond_to_missing?(*args)
      super || implicit_document.respond_to?(*args)
    end
  end
end
