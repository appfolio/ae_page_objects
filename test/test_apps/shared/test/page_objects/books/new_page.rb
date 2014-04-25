module PageObjects
  module Books
    class NewPage < ::AePageObjects::Document
      extend HasBookForm

      path :new_book
      path :books

      has_book_form

      def save!
        title = self.title.value

        node.find("input[type=submit]").click

        window.document_as do |current_document|
          current_document.matches(Books::ShowPage) do |page|
            page.title.text == title
          end

          current_document.matches(self.class) do |page|
            ! page.form.error_messages.empty?
          end
        end
      end
    end
  end
end
