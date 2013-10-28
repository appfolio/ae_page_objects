module PageObjects
  module Books
    class ShowPage < ::AePageObjects::Document
      path :book

      element :title

      def edit!
        node.click_link("Edit")
        Books::EditPage.new
      end
    end
  end
end
