module TestApp
  module AePageObjects
    module Authors
      class NewPage < ::AePageObjects::Document
        
        path :new_author

        form_for "author" do
          field :first_name
          field :last_name
          
          has_many :books, :locator => "#author_books", :row_xpath => ".//*[contains(@class, 'some-books-fool')]//*[contains(@class,'row') and not(contains(@style,'display'))]" do
            field :title
          end
        end
        
        class Rating < ::AePageObjects::Element
          node :star, :locator => ".star"
          
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
        
        node :rating, :as => Rating, :locator => "#rating"
        
        node :nested_rating, :locator => "#rating" do
          node :star, :locator => ".star"
          
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
end
