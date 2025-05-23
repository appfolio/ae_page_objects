module PageObjects
  module Books
    module HasBookForm

      def has_book_form
        form_for :form, :name => "book" do
          collection :errors, :locator => '#error_explanation', :item_locator => 'li'

          def error_messages
            errors.map(&:text)
          end

          element :title

          element :index, :name => "index_attributes", :locator => "#book_index" do
            element :pages
          end

          element :author, :name => "author_attributes" do
            element :first_name
          end
        end
      end
    end
  end
end
