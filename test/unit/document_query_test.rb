require 'unit_helper'

module AePageObjects
  class DocumentQueryTest < Test::Unit::TestCase

    def test_default_document_class
      hello_class = ::AePageObjects::Document.new_subclass
      kitty_class = ::AePageObjects::Document.new_subclass

      document_query = DocumentQuery.new do |query|
        query.matches(hello_class)
        query.matches(kitty_class)
      end

      assert_equal hello_class, document_query.default_document_class
    end

    def test_permitted_types_dump
      hello_class = ::AePageObjects::Document.new_subclass do
        def self.name
          "hello"
        end
      end

      kitty_class = ::AePageObjects::Document.new_subclass do
        def self.name
          "kitty"
        end
      end

      document_query = DocumentQuery.new do |query|
        query.matches(hello_class)
        query.matches(kitty_class)
      end

      assert_equal ["hello", "kitty"].inspect, document_query.permitted_types_dump

      # it's memoized
      assert_equal ["hello", "kitty"].inspect, document_query.permitted_types_dump
    end

    def test_query_conditions
      block_condition = proc do |page|
        page.is_starbucks?
      end
      document_class = mock
      conditions = DocumentQuery::Condition.new(document_class, {:ignore_current => true, :url => 'www.starbucks.com', :title => 'Coffee'}, &block_condition)

      page = setup_page_for_conditions
      assert_equal true, conditions.send(:match?, page)

      page = setup_page_for_conditions(:current_url => "www.whatever.com/bleh")
      assert_equal false, conditions.send(:match?, page)

      page = setup_page_for_conditions(:title => "Best Darn Stuff")
      assert_equal false, conditions.send(:match?, page)
    end

    def test_new__document_classes
      kitty_class = AePageObjects::Document.new_subclass
      bunny_class = AePageObjects::Document.new_subclass

      query = DocumentQuery.new(kitty_class, bunny_class)
      assert_equal [kitty_class, bunny_class], query.conditions.map(&:document_class)
      assert_equal([{}, {}], query.conditions.map(&:document_conditions))
    end

    def test_new__document_class__page_condition
      kitty_class = ::AePageObjects::Document.new_subclass
      bunny_class = ::AePageObjects::Document.new_subclass

      query = DocumentQuery.new(kitty_class, :url => "somewhere")
      assert_equal [kitty_class], query.conditions.map(&:document_class)
      assert_equal({:url => "somewhere"}, query.conditions.first.document_conditions)
    end

    def test_new__document_class__page_condition__block
      kitty_class = ::AePageObjects::Document.new_subclass

      block_condition = proc do |page|
        page.is_starbucks?
      end

      query = DocumentQuery.new(kitty_class, :url => "somewhere", &block_condition)

      assert_equal [kitty_class], query.conditions.map(&:document_class)
      assert_equal({:url => "somewhere", :block => block_condition}, query.conditions.first.document_conditions)
    end

    def test_new__document_class__block
      kitty_class = ::AePageObjects::Document.new_subclass

      block_condition = proc do |page|
        page.is_starbucks?
      end

      query = DocumentQuery.new(kitty_class, &block_condition)

      assert_equal [kitty_class], query.conditions.map(&:document_class)
      assert_equal({:block => block_condition}, query.conditions.first.document_conditions)
    end

    def test_new__block__matches
      kitty_class = ::AePageObjects::Document.new_subclass

      query = DocumentQuery.new do |query|
        query.matches(kitty_class)
      end

      assert_equal [kitty_class], query.conditions.map(&:document_class)
      assert_equal({}, query.conditions.first.document_conditions)
    end

    def test_new__block__no_matches
      kitty_class = ::AePageObjects::Document.new_subclass

      assert_raise ArgumentError do
        query = DocumentQuery.new do |query|
        end
      end
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
