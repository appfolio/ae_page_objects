require 'unit_helper'

module AePageObjects
  class ElementProxyTest < ActiveSupport::TestCase
    
    def test_respond_to_can_find_methods_without_element_not_found
      proxy = new_proxy
      assert proxy.respond_to?(:class)
      assert proxy.respond_to?(:presence)
      assert proxy.respond_to?(:dom_id)
      assert_false proxy.respond_to?(:whiz_bang!)
    end
        
    def test_initialize__no_block
      proxy = new_proxy
      assert_is_proxy proxy
      
      element_class.expects(:new).returns(:yay)
      assert_equal :yay, proxy.send(:element)
    end
    
    def test_initialize__block
      element_class.expect_initialize
      
      instance_passed_to_block = nil
      proxy = new_proxy do |element|
        instance_passed_to_block = element
      end
      assert_is_proxy proxy
      
      assert_is_element instance_passed_to_block
      assert_is_element proxy.presence
      
      assert_equal instance_passed_to_block, proxy.presence
      assert proxy.present?
    end
    
    def test_methods_forwarded
      proxy = new_proxy
      
      element_class.expect_initialize
      element_class.any_instance.expects(:kesslerize_my_love!).returns(:my_deepest_wishes).twice
      assert_equal :my_deepest_wishes, proxy.kesslerize_my_love!
      assert_equal :my_deepest_wishes, proxy.kesslerize_my_love!
    end
  
    def test_presence
      proxy = new_proxy
      
      element_class.expect_initialize
      assert_is_element proxy.presence
    end
    
    def test_presence__element_not_found
      proxy = new_proxy
      
      element_class.expects(:new).raises(Capybara::ElementNotFound)
      assert_nil proxy.presence
    end
    
    def test_present
      proxy = new_proxy
      
      element_class.expect_initialize
      assert proxy.present?
    end
    
    def test_present__element_not_found
      proxy = new_proxy
      
      element_class.expects(:new).raises(Capybara::ElementNotFound)
      assert_false proxy.present?
    end
    
    def test_not_present
      proxy = new_proxy
      
      element_class.expects(:new).raises(Capybara::ElementNotFound)
      assert proxy.not_present?
    end
    
    def test_visible
      proxy = new_proxy
      
      element_class.expect_initialize
      element_class.any_instance.expects(:visible?).returns(true)
      assert proxy.visible?
    end
    
    def test_visible__element_not_found
      proxy = new_proxy
      
      element_class.expects(:new).raises(Capybara::ElementNotFound)
      assert_false proxy.visible?
    end
    
    def test_visible__false
      proxy = new_proxy
      
      element_class.expect_initialize
      element_class.any_instance.expects(:visible?).returns(false)
      assert_false proxy.visible?
    end
    
  private
  
    def element_class
      @element_class ||= Element.new_subclass do 
        def self.expect_initialize
          any_instance.expects(:initialize).with(1, 2)
        end
      end
    end
  
    def new_proxy(&block)
      ElementProxy.new(element_class, 1, 2, &block)
    end
  
    def assert_is_proxy(proxy)
      assert proxy.is_a?(ElementProxy)
      assert proxy.is_a?(element_class)
    end
  
    def assert_is_element(element)
      assert element.is_a?(element_class)
      assert_false element.is_a?(ElementProxy)
    end
  end
end
