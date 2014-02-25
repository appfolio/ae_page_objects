require 'unit_helper'

module AePageObjects
  class ElementProxyTest < Test::Unit::TestCase
    
    def test_respond_to_can_find_methods_without_element_not_found
      proxy = new_proxy
      assert proxy.respond_to?(:class)
      assert proxy.respond_to?(:presence)
      assert proxy.respond_to?(:__full_name__)
      assert_false proxy.respond_to?(:whiz_bang!)
    end
        
    def test_initialize__no_block
      proxy = new_proxy
      assert_is_proxy proxy
      
      element_class.expects(:new).returns(:yay)
      assert_equal :yay, proxy.send(:element)
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

      with_stubbed_wait_for do
        element_class.expect_initialize
        assert_false proxy.not_present?
      end
    end

    def test_not_present__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(Capybara::ElementNotFound)
        assert proxy.not_present?
      end
    end

    def test_visible
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(true)
        assert proxy.visible?
      end
    end
    
    def test_visible__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(Capybara::ElementNotFound)
        assert_false proxy.visible?
      end
    end
    
    def test_not_visible
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(false)
        assert proxy.not_visible?
      end

      with_stubbed_wait_for do
        element_class.any_instance.expects(:visible?).returns(true)
        assert ! proxy.not_visible?
      end
    end
    
    def test_not_visible__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(Capybara::ElementNotFound)
        assert proxy.not_visible?
      end
    end

    def test_visible__false
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(false)
        assert_false proxy.visible?
      end
    end

    private

    def unstub_wait_for
      (class << Waiter; self; end).send(:alias_method, :wait_for, :wait_for_whatever)

      (class << Waiter; self; end).send(:undef_method, :wait_for_whatever)
    end

    def stub_wait_for
      wait_for_mock = mock(:wait_for_called => true)
      (class << Waiter; self; end).send(:alias_method, :wait_for_whatever, :wait_for)

      (class << Waiter; self; end).send(:define_method, :wait_for) do |&block|
        wait_for_mock.wait_for_called
        block.call
      end
    end

    def with_stubbed_wait_for
      stub_wait_for
      yield
    ensure
      unstub_wait_for
    end

    def element_class
      @element_class ||= Element.new_subclass do 
        def self.expect_initialize
          any_instance.expects(:initialize).with(1, 2)
        end
      end
    end
  
    def new_proxy
      ElementProxy.new(element_class, 1, 2)
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
