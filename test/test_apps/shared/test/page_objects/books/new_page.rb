module TestApp
  module PageObjects
    module Books
      class NewPage < ::AePageObjects::Document
        
        path :new_book
        
        def loaded_locator
          "form#new_book"
        end
      
        form_for "book" do
          element :title
          
          element :index, :locator => "#book_index" do
            element :pages
          end
          
          element :author do
            element :first_name
          end
        end
      end
    end
  end
end
