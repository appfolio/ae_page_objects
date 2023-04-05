require 'unit_helper'

module AePageObjects
  class CollectionTest < AePageObjectsTestCase

    def test_css_item_locator
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock(allow_reload!: nil)
      parent_node.expects(:first).with("#18_holder", { minimum: 0 }).returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => ".some_class")

      assert_equal ".//*[contains(concat(' ',normalize-space(@class),' '),' some_class ')]", magazine.send(:item_xpath)
    end

    def test_xpath_item_locator
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock(allow_reload!: nil)
      parent_node.expects(:first).with("#18_holder", { minimum: 0 }).returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => [:xpath, ".//div[text()='Example Text']"])

      assert_equal ".//div[text()='Example Text']", magazine.send(:item_xpath)
    end

    def test_xpath_item_locator__matches_exact_text
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock(allow_reload!: nil)
      parent_node.expects(:first).with("#18_holder", { minimum: 0 }).returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => [
        :xpath,
        XPath.descendant(:div)[XPath.text.is('Example Text')]
      ])

      assert_equal ".//div[(./text() = 'Example Text')]", magazine.send(:item_xpath)
    end

    def test_xpath_item_locator__respects_passed_exact_option
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock(allow_reload!: nil)
      parent_node.expects(:first).with("#18_holder", { minimum: 0 }).returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => [
        :xpath,
        XPath.descendant(:div)[XPath.text.is('Example Text')],
        :exact => false
      ])

      assert_equal ".//div[contains(./text(), 'Example Text')]", magazine.send(:item_xpath)
    end

    def test_locator_options__blank
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      magazine_node = mock(allow_reload!: nil)
      parent_node = mock(:first => magazine_node)
      parent = mock(:node => parent_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => ".some_class")
      magazine.stubs(:item_xpath).returns('item_xpath')

      bullet1_stub = mock(allow_reload!: nil)
      magazine_node.expects(:all).with(:xpath, 'item_xpath', {}).returns([bullet1_stub])
      magazine_node.expects(:first).with(:xpath, '(item_xpath)[1]', { minimum: 0 }).returns(bullet1_stub)
      assert_equal bullet1_stub, magazine.at(0).node
    end

    def test_locator_options__present
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      magazine_node = mock(allow_reload!: nil)
      parent_node = mock(:first => magazine_node)
      parent = mock(:node => parent_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => [".some_class", { :capybara => 'options' }])
      magazine.stubs(:item_xpath).returns("item_xpath")

      bullet1_stub = mock(allow_reload!: nil)
      magazine_node.expects(:all).with(:xpath, 'item_xpath', { capybara: 'options' }).returns([bullet1_stub])
      magazine_node.expects(:first).with(:xpath, "(item_xpath)[1]", { capybara: 'options', minimum: 0 }).returns(bullet1_stub)
      assert_equal bullet1_stub, magazine.at(0).node
    end

    def test_empty
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock(allow_reload!: nil)
      parent_node.expects(:first).with("#18_holder", { minimum: 0 }).returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder")
      magazine.stubs(:item_xpath).returns("item_xpath")

      magazine_node.stubs(:all).with(:xpath, "item_xpath", {}).returns([])

      assert_equal 0, magazine.size

      magazine.each do |bullet|
        raise "Shouldn't be called"
      end

      assert_nil magazine.at(0)
      assert_nil magazine.at(1000)
      assert_nil magazine.first
      assert_nil magazine.last
      assert_equal [], magazine.to_a
    end

    def test_non_empty
      bullets = Class.new(AePageObjects::Element)
      clip    = Class.new(AePageObjects::Collection) do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = stub(allow_reload!: nil)
      parent_node.expects(:first).with("#18_holder", { minimum: 0 }).returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder")
      magazine.stubs(:item_xpath).returns("item_xpath")

      bullet1_stub = stub(allow_reload!: nil)
      bullet2_stub = stub(allow_reload!: nil)
      magazine_node.stubs(:all).with(:xpath, "item_xpath", {}).returns([bullet1_stub, bullet2_stub])

      assert_equal 2, magazine.size

      magazine_node.expects(:first).with(:xpath, "(item_xpath)[1]", { minimum: 0 }).returns(bullet1_stub)
      magazine_node.expects(:first).with(:xpath, "(item_xpath)[2]", { minimum: 0 }).returns(bullet2_stub)
      each_block_call_count = 0
      magazine.each do |bullet|
        bullet.name
        each_block_call_count += 1
      end
      assert_equal 2, each_block_call_count

      magazine_node.expects(:first).with(:xpath, "(item_xpath)[1]", { minimum: 0 }).times(2).returns(bullet1_stub)
      assert_equal bullet1_stub, magazine.at(0).node
      assert_equal bullet1_stub, magazine.first.node

      magazine_node.expects(:first).with(:xpath, "(item_xpath)[2]", { minimum: 0 }).times(2).returns(bullet2_stub)
      assert_equal bullet2_stub, magazine.at(1).node
      assert_equal bullet2_stub, magazine.last.node

      magazine_node.expects(:first).with(:xpath, "(item_xpath)[1]", { minimum: 0 }).returns(bullet1_stub)
      magazine_node.expects(:first).with(:xpath, "(item_xpath)[2]", { minimum: 0 }).returns(bullet2_stub)
      assert_equal [bullet1_stub, bullet2_stub], magazine.map(&:node)

      assert_equal nil, magazine.at(1000)
    end
  end
end
