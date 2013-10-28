module AePageObjects
  class VariableDocument

    # Remove all instance methods so even things like class()
    # get handled by method_missing(). <lifted from activerecord>
    instance_methods.each do |m|
      unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|tap)$|^__|^respond_to|is_a?/
        undef_method m
      end
    end

    def initialize(*documents)
      @documents = documents
    end

    def is_a?(document_class)
      super || !! as_a(document_class)
    rescue AePageObjects::Error
      false
    end

    def as_a(document_class)
      unless @documents.include?(document_class)
        raise InvalidCast, "Cannot cast as #{document_class.name} from #{@documents.map(&:name)}"
      end

      document_class.new
    end

  private

    def implicit_document_class
      @implicit_document_class ||= @documents.first
    end

    def implicit_document
      @implicit_document ||= implicit_document_class.new
    end

    def method_missing(name, *args, &block)
      implicit_document.__send__(name, *args, &block)
    end

    def respond_to?(*args)
      super || implicit_document_class.allocate.respond_to?(*args)
    end
  end
end
