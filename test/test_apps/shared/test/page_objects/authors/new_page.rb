module TestApp
  module PageObjects
    module Authors
      class NewPage < ::AePageObjects::Document
        
        path :new_author

        form_for "author" do
          node :first_name
          node :last_name
          
          nodes :books, :locator => "#author_books", :row_xpath => ".//*[contains(@class, 'some-books-fool')]//*[contains(@class,'row') and not(contains(@style,'display'))]" do
            node :title
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
        
        node :missing, :locator => "#does_not_exist"
        
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
