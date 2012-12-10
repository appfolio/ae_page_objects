module AePageObjects
  class HasOne < Element
    def dom_id
      if parent.respond_to?(:dom_id)
        "#{parent.dom_id}_#{dom_name}_attributes"
      else
        "#{dom_name}_attributes"
      end
    end
  end
end
