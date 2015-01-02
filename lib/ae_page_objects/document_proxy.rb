module AePageObjects
  class DocumentProxy

    def initialize(loaded_page, query)
      @loaded_page = loaded_page
      @query = query

      implicit_document_proc = lambda { implicit_document }

      forwarded_methods = @loaded_page.public_methods - self.class.public_instance_methods(false) - self.class.private_instance_methods(false) - [:instance_variable_get] - ["instance_variable_get"]
      mod = Module.new do
        forwarded_methods.each do |name|
          define_method(name) do |*args, &block|
            implicit_document_proc.call.send(name, *args, &block)
          end
        end
      end

      extend(mod)
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

    def respond_to_missing?(*args)
      super || implicit_document.respond_to?(*args)
    end
  end
end
