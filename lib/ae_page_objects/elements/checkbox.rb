require 'ae_page_objects/element'

module AePageObjects
  class Checkbox < AePageObjects::Element
    def check
      node.set true
    end

    def uncheck
      node.set false
    end

    def checked?
      node.native.attribute('checked').to_s.eql?("true")
    end

    def unchecked?
      !checked?
    end
  end
end
