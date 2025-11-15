module PageObjects
  module Authors
    class ShowPage < AePageObjects::Document
      path :author

      element :first_name
      element :last_name

      def close_via_js!
        node.click_link("Close")
        stale!
      end
    end
  end
end
