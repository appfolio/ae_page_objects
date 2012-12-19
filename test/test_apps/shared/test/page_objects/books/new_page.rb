module TestApp
  module PageObjects
    module Books
      class NewPage < ::AePageObjects::Document
        
        path :new_book
        
        def loaded_locator
          "form#new_book"
        end
      
        form_for "book" do
          node :title
          
          node :index, :locator => "#book_index" do
            node :pages
          end
          
          node :author do
            node :first_name
          end
        end
      end
    end
  end
end
