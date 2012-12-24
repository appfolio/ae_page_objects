module AePageObjects
  class HasOne < Element
    def __full_name__
      if parent.respond_to?(:__full_name__)
        "#{parent.__full_name__}_#{__name__}_attributes"
      else
        "#{__name__}_attributes"
      end
    end
  end
end
