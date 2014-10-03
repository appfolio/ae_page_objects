module AePageObjects
  class Select < Element

    collection :options,
      locator: [:xpath, "."],
      item_locator: 'option'

    def set(value)
      node.select(value)
    end

  end
end
