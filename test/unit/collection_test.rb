require 'unit_helper'

module AePageObjects
  class CollectionTest < Test::Unit::TestCase

    def test_css_item_locator
      bullets = ::AePageObjects::Element.new_subclass
      clip    = ::AePageObjects::Collection.new_subclass do
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock
      parent_node.expects(:find).with("#18_holder").returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder", :item_locator => ".some_class")
      assert_equal ".//*[contains(concat(' ', normalize-space(@class), ' '), ' some_class ')]", magazine.item_xpath
    end

    def test_empty
      bullets = ::AePageObjects::Element.new_subclass
      clip    = ::AePageObjects::Collection.new_subclass do 
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock
      parent_node.expects(:find).with("#18_holder").returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder")
      
      magazine_node.stubs(:all).with(:xpath, magazine.item_xpath).returns([])

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
      bullets = ::AePageObjects::Element.new_subclass
      clip    = ::AePageObjects::Collection.new_subclass do 
        self.item_class = bullets
      end

      parent_node = mock
      parent = mock
      parent.stubs(:node).returns(parent_node)

      magazine_node = mock
      parent_node.expects(:find).with("#18_holder").returns(magazine_node)

      magazine = clip.new(parent, :name => "18_holder")
      
      bullet1_stub = mock
      bullet2_stub = mock
      magazine_node.stubs(:all).with(:xpath, magazine.item_xpath).returns([bullet1_stub, bullet2_stub])

      assert_equal 2, magazine.size
      
      magazine_node.expects(:find).with(:xpath, "#{magazine.item_xpath}[1]").returns(bullet1_stub)
      magazine_node.expects(:find).with(:xpath, "#{magazine.item_xpath}[2]").returns(bullet2_stub)
      each_block_call_count = 0
      magazine.each do |bullet|
        bullet.name
        each_block_call_count += 1
      end
      assert_equal 2, each_block_call_count
      
      magazine_node.expects(:find).with(:xpath, "#{magazine.item_xpath}[1]").times(2).returns(bullet1_stub)
      assert_equal bullet1_stub, magazine.at(0).node
      assert_equal bullet1_stub, magazine.first.node
            
      magazine_node.expects(:find).with(:xpath, "#{magazine.item_xpath}[2]").times(2).returns(bullet2_stub)
      assert_equal bullet2_stub, magazine.at(1).node
      assert_equal bullet2_stub, magazine.last.node
      
      magazine_node.expects(:find).with(:xpath, "#{magazine.item_xpath}[1]").returns(bullet1_stub)
      magazine_node.expects(:find).with(:xpath, "#{magazine.item_xpath}[2]").returns(bullet2_stub)
      assert_equal [bullet1_stub, bullet2_stub], magazine.map(&:node)
      
      assert_equal nil, magazine.at(1000)
    end
  end
end
