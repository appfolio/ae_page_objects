module TestApp
  module PageObjects
    module Books
      class NewPage < ::AePageObjects::Document
        
        path :new_book
        
        def loaded_locator
          "form#new_book"
        end
      
        form_for "book" do
          field :title
          
          has_one :index, :locator => "#book_index" do
            field :pages
          end
          
          has_one :author do
            field :first_name
          end
        end
      end
    end
  end
end
