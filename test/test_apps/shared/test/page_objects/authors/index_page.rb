module PageObjects
  module Authors
    class IndexPage < AePageObjects::Document
      path :authors

      class Table < AePageObjects::Collection
        self.item_class = Class.new(AePageObjects::Element) do
        private
          def configure(*)
            super
            @name = nil
          end
        end

      private
        def configure(*)
          super
          @name = nil
        end
      end

      collection :authors,
                 :is => Table,
                 :locator => ".author_list",
                 :item_locator => "tr.author_info" do

        element :first_name, :locator => '.first_name'
        element :last_name, :locator => '.last_name'

        def show_in_new_window
          node.click_link("Show In New Window")
        end

        def show_in_new_window!
          node.click_link("Show In New Window")

          browser.find_document(ShowPage)
        end

        def show_in_new_window_with_name!(name)
          node.click_link("Show In New Window")

          browser.find_document(PageObjects::Authors::ShowPage) do |author|
            author.first_name.text == name
          end
        end

        def delayed_show!
          node.find(".js-delay-show").click
          window.change_to(ShowPage)
        end

        def show!
          node.click_link("Show")
          window.change_to(ShowPage)
        end
      end
    end
  end
end
