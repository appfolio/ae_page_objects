module PageObjects
  module Books
    class NewPage < AePageObjects::Document
      extend HasBookForm

      path :new_book
      path :books

      has_book_form

      def save!
        title = self.title.value

        node.find("input[type=submit]").click

        window.change_to do |window|
          window.matches(Books::ShowPage) do |page|
            page.title.text == title
          end

          window.matches(self.class) do |page|
            ! page.form.error_messages.empty?
          end
        end
      end
    end
  end
end
