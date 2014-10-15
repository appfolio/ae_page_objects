module AePageObjects
  class Select < Element

    collection :options,
      :locator => [:xpath, "."],
      :item_locator => 'option' do

        def selected?
          node.selected?
        end

        def select
          node.select_option
        end

      end

    def set(value)
      node.select(value)
    end

    def selected_option
      options.find {|o| o.selected? }
    end
  end
end
