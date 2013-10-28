module PageObjects
  module Books
    class NewPage < ::AePageObjects::Document

      path :new_book

      def loaded_locator
        "form#new_book"
      end

      form_for "book" do
        element :title

        element :index, :name => "index_attributes", :locator => "#book_index" do
          element :pages
        end

        element :author, :name => "author_attributes" do
          element :first_name
        end
      end

      def save!
        node.click_button("Create Book")
        Books::ShowPage.new
      end
    end
  end
end
