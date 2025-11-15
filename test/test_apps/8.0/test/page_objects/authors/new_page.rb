module PageObjects
  module Authors
    class NewPage < AePageObjects::Document
      path :new_author

      form_for "author" do
        element :first_name
        element :last_name

        collection :books,
                   :name         => "books_attributes",
                   :locator      => "#author_books",
                   :item_locator => ".a-book-fool" do
          element :title
        end
      end

      class Rating < AePageObjects::Element
        element :star, locator: ['.star', visible: :all]

        def show_star
          node.find(".show_star").click
        end

        def hide_star
          node.find(".hide_star").click
        end

        def add_star
          node.find(".add_star").click
        end

        def remove_star
          node.find(".remove_star").click
        end
      end

      element :missing, :locator => "#does_not_exist"

      element :rating, :is => Rating, :locator => "#rating"

      element :nested_rating, :name => "nested_rating_attributes", :locator => "#rating" do
        element :star, locator: ['.star', visible: :all]

        def show_star
          node.find(".show_star").click
        end

        def hide_star
          node.find(".hide_star").click
        end

        def remove_star
          node.find(".remove_star").click
        end
      end
    end
  end
end
