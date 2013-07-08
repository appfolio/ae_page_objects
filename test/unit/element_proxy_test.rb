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

      stub_capybara_session_wait_until

      element_class.expect_initialize
      assert_false proxy.not_present?
    end

    def test_not_present__element_not_found
      proxy = new_proxy

      stub_capybara_session_wait_until
      
      element_class.expects(:new).raises(Capybara::ElementNotFound)
      assert proxy.not_present?
    end
    
    def test_not_present__timeout
      proxy = new_proxy

      fake_session = stub
      fake_session.expects(:wait_until).raises(Capybara::TimeoutError)
      Capybara.stubs(:current_session).returns(fake_session)

      assert !proxy.not_present?
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
    
    def test_not_visible
      proxy = new_proxy
      
      stub_capybara_session_wait_until
      
      element_class.expect_initialize
      element_class.any_instance.expects(:visible?).returns(false)
      assert proxy.not_visible?
      
      stub_capybara_session_wait_until
      
      element_class.any_instance.expects(:visible?).returns(true)
      assert ! proxy.not_visible?
    end
    
    def test_not_visible__element_not_found
      proxy = new_proxy
      
      stub_capybara_session_wait_until

      element_class.expects(:new).raises(Capybara::ElementNotFound)
      assert proxy.not_visible?
    end
    
    def test_not_visible__timeout
      proxy = new_proxy
      
      fake_session = stub
      fake_session.expects(:wait_until).raises(Capybara::TimeoutError)
      Capybara.stubs(:current_session).returns(fake_session)

      assert !proxy.not_visible?
    end
    
    def test_visible__false
      proxy = new_proxy
      
      element_class.expect_initialize
      element_class.any_instance.expects(:visible?).returns(false)
      assert_false proxy.visible?
    end
    
  private
    
    def stub_capybara_session_wait_until
      fake_session_class = Class.new do
        def wait_until
          verified_called
          yield
        end
      end
      
      fake_session = fake_session_class.new
      fake_session.expects :verified_called
      Capybara.expects(:current_session).returns(fake_session)
    end
  
    def stub_capybara_session_wait_until
      fake_session_class = Class.new do
        def wait_until
          verified_called
          yield
        end
      end
    
      fake_session = fake_session_class.new
      fake_session.expects :verified_called
      Capybara.stubs(:current_session).returns(fake_session)
    end
  
    def element_class
      @element_class ||= Element.new_subclass do 
        def self.expect_initialize
          silence_warnings do
            any_instance.expects(:initialize).with(1, 2)
          end
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
