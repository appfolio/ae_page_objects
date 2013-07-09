module TestApp
  module PageObjects
    module Authors
      class IndexPage < AePageObjects::Document
        path :authors

        class Table < AePageObjects::Collection
          self.item_class = AePageObjects::Element.new_subclass do
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
                   :locator => "table",
                   :row_xpath => "//tr" do

          element :first_name, :locator => '.first_name'
          element :last_name, :locator => '.last_name'

          def show_in_new_window
            node.click_link("Show In New Window")
          end

          def show!
            node.click_link("Show")
            ShowPage.new
          end
        end
      end
    end
  end
end
