module PageObjects
  module Authors
    class NewPage < ::AePageObjects::Document

      path :new_author

      form_for "author" do
        element :first_name
        element :last_name

        collection :books,
                   :name      => "books_attributes",
                   :locator   => "#author_books",
                   :row_xpath => ".//*[contains(@class, 'some-books-fool')]//*[contains(@class,'row') and not(contains(@style,'display'))]" do
          element :title
        end
      end

      class Rating < ::AePageObjects::Element
        element :star, :locator => ".star"

        def show_star
          find(".show_star").click
        end

        def hide_star
          find(".hide_star").click
        end

        def remove_star
          find(".remove_star").click
        end
      end

      element :missing, :locator => "#does_not_exist"

      element :rating, :is => Rating, :locator => "#rating"

      element :nested_rating, :name => "nested_rating_attributes", :locator => "#rating" do
        element :star, :locator => ".star"

        def show_star
          find(".show_star").click
        end

        def hide_star
          find(".hide_star").click
        end

        def remove_star
          find(".remove_star").click
        end
      end
    end
  end
end
