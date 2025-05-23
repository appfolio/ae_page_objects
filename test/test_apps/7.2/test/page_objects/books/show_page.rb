module PageObjects
  module Books
    class ShowPage < AePageObjects::Document
      path :book
      path :view_book

      element :title

      def edit!
        node.click_link("Edit")
        window.change_to(Books::EditPage)
      end
    end
  end
end
