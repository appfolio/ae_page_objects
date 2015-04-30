module AePageObjects
  class Select < Element
    def set(value)
      node.select(value)
    end

    def selected_text
      node.find('[selected="selected"]').text
    end
  end
end
