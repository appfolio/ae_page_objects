require 'unit_helper'

module AePageObjects
  class CollectionTest < ActiveSupport::TestCase
  
    def test_empty
      bullets = ::AePageObjects::Element.new_subclass
      clip    = ::AePageObjects::Collection.new_subclass do 
        self.item_class = bullets
      end
      
      parent = mock
      
      magazine_stub = mock
      parent.expects(:find).with("#18_holder").returns(magazine_stub)
      magazine = clip.new(parent, "18_holder")
      
      magazine_stub.stubs(:all).with(:xpath, magazine.row_xpath).returns([])

      assert_equal 0, magazine.size
      
      magazine.each do |bullet|
        raise "Shouldn't be called"
      end
      
      assert_nil magazine.at(0)
      assert_nil magazine.at(1000)
      assert_nil magazine.first
      assert_nil magazine.last
      assert_equal [], magazine.all
    end
    
    def test_non_empty
      bullets = ::AePageObjects::Element.new_subclass
      clip    = ::AePageObjects::Collection.new_subclass do 
        self.item_class = bullets
      end
      
      parent = mock
      
      magazine_stub = mock
      parent.expects(:find).with("#18_holder").returns(magazine_stub)
      magazine = clip.new(parent, "18_holder")
      
      bullet1_stub = mock
      bullet2_stub = mock
      magazine_stub.stubs(:all).with(:xpath, magazine.row_xpath).returns([bullet1_stub, bullet2_stub])

      assert_equal 2, magazine.size
      
      magazine_stub.expects(:find).with(:xpath, "#{magazine.row_xpath}[1]").returns(bullet1_stub)
      magazine_stub.expects(:find).with(:xpath, "#{magazine.row_xpath}[2]").returns(bullet2_stub)
      each_block_call_count = 0
      magazine.each do |bullet|
        each_block_call_count += 1
      end
      assert_equal 2, each_block_call_count
      
      magazine_stub.expects(:find).with(:xpath, "#{magazine.row_xpath}[1]").times(2).returns(bullet1_stub)
      assert_equal bullet1_stub, magazine.at(0).node
      assert_equal bullet1_stub, magazine.first.node
            
      magazine_stub.expects(:find).with(:xpath, "#{magazine.row_xpath}[2]").times(2).returns(bullet2_stub)
      assert_equal bullet2_stub, magazine.at(1).node
      assert_equal bullet2_stub, magazine.last.node
      
      magazine_stub.expects(:find).with(:xpath, "#{magazine.row_xpath}[1]").returns(bullet1_stub)
      magazine_stub.expects(:find).with(:xpath, "#{magazine.row_xpath}[2]").returns(bullet2_stub)
      assert_equal [bullet1_stub, bullet2_stub], magazine.all.map(&:node)
      
      assert_equal nil, magazine.at(1000)
    end
  end
end