require 'unit_helper'

module AePageObjects
  class DocumentFinder
    class ConditionsTest < Test::Unit::TestCase

      def test_conditions
        block_condition = proc do |page|
          page.is_starbucks?
        end
        conditions = DocumentFinder::Conditions.new({:ignore_current => true, :url => 'www.starbucks.com', :title => 'Coffee'}, &block_condition)

        page = setup_page_for_conditions
        assert_equal true, conditions.match?(page)

        page = setup_page_for_conditions(:current_url => "www.whatever.com/bleh")
        assert_equal false, conditions.match?(page)

        page = setup_page_for_conditions(:title => "Best Darn Stuff")
        assert_equal false, conditions.match?(page)
      end

      private

      def setup_page_for_conditions(options = {})
        options = {
          :current_url    => "www.starbucks.com/bleh",
          :is_starbucks?  => true,
          :title          => "Best Darn Coffee",
        }.merge(options)

        capybara_stub.browser.stubs(:title).returns(options[:title])
        stub(:current_url => options[:current_url], :is_starbucks? => options[:is_starbucks?])
      end
    end
  end
end