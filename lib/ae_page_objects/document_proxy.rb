module AePageObjects
  class DocumentProxy

    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord>
    instance_methods.each do |m|
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to|is_a?|instance_variable_get/
        undef_method m
      end
    end

    def initialize(loaded_page, document_loader)
      @loaded_page     = loaded_page
      @document_loader = document_loader
    end

    def is_a?(document_class)
      super || @loaded_page.is_a?(document_class)
    end

    def as_a(document_class)
      if @loaded_page.is_a?(document_class)
        return @loaded_page
      end

      raise DocumentLoadError, "#{document_class.name} not expected. Allowed types: #{@document_loader.permitted_types_dump}"
    end

  private

    def implicit_document
      @implicit_document ||= as_a(implicit_document_class)
    end

    def implicit_document_class
      @implicit_document_class ||= @document_loader.default_document_class
    end

    def method_missing(name, *args, &block)
      implicit_document.__send__(name, *args, &block)
    end

    def respond_to?(*args)
      super || implicit_document_class.allocate.respond_to?(*args)
    end
  end
end
