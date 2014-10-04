module AePageObjects
  class Select < Element

    collection :options,
      :locator => [:xpath, "."],
      :item_locator => 'option'

    def set(value)
      node.select(value)
    end

    def selected_option
      options.find {|o| o.value == value }
    end
  end
end
