module AePageObjects
  class HasOne < Element
    def dom_id
      if parent.respond_to?(:dom_id)
        "#{parent.dom_id}_#{__name__}_attributes"
      else
        "#{__name__}_attributes"
      end
    end
  end
end
