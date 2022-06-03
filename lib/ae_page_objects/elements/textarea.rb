module AePageObjects
  class Textarea < Element
    def set(value)
      node.set(value, { clear: clear_keys })
    end

    private

    def clear_keys
      [[:command, 'a'], :backspace]
    end
  end
end
