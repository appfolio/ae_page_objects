require 'ae_page_objects/element'

module AePageObjects
  class Select < AePageObjects::Element
    def set(value)
      node.select(value)
    end
  end
end
