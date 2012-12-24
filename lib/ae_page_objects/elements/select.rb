module AePageObjects
  class Select < Element
    def set(value)
      node.select(value)
    end
  end
end
