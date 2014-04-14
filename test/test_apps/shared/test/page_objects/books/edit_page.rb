module PageObjects
  module Books
    class EditPage < ::AePageObjects::Document
      extend HasBookForm

      path :edit_book

      has_book_form

      def save!
        node.find("input[type=submit]").click
        window.document_as(Books::ShowPage, self.class)
      end
    end
  end
end
