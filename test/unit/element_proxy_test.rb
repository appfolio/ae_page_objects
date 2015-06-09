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
      assert_equal :yay, proxy.send(:implicit_element)
    end

    def test_methods_forwarded
      proxy = new_proxy

      element_class.expect_initialize
      element_class.any_instance.expects(:kesslerize_my_love!).returns(:my_deepest_wishes).twice
      assert_equal :my_deepest_wishes, proxy.kesslerize_my_love!
      assert_equal :my_deepest_wishes, proxy.kesslerize_my_love!
    end

    def test_visible
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(true)
        assert proxy.visible?
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

    def test_visible__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
        assert_false proxy.visible?
      end
    end

    def test_hidden
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(false)
        assert proxy.hidden?
      end

      with_stubbed_wait_for do
        element_class.any_instance.expects(:visible?).returns(true)
        assert ! proxy.hidden?
      end
    end

    def test_hidden__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
        assert proxy.hidden?
      end
    end

    def test_present
      proxy = new_proxy

      element_class.expect_initialize
      assert proxy.present?
    end

    def test_present__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
        assert_false proxy.present?
      end
    end

    def test_absent
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        assert_false proxy.absent?
      end
    end

    def test_absent__element_not_found
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
        assert proxy.absent?
      end
    end

    def test_presence
      proxy = new_proxy

      element_class.expect_initialize
      assert_is_element proxy.presence
    end

    def test_presence__element_not_found
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert_nil proxy.presence
    end

    def test_wait_until_visible
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(true)

        assert_nothing_raised do
          proxy.wait_until_visible
        end
      end
    end

    def test_wait_until_visible__timeout
      proxy = new_proxy

      element_class.expect_initialize
      element_class.any_instance.expects(:visible?).returns(false)

      raised = nil

      with_stubbed_wait_for do
        raised = assert_raise ElementNotVisible do
          proxy.wait_until_visible
        end
      end

      assert_includes raised.message, element_class.to_s
    end

    def test_wait_until_hidden
      proxy = new_proxy

      with_stubbed_wait_for do
        element_class.expect_initialize
        element_class.any_instance.expects(:visible?).returns(false)

        assert_nothing_raised do
          proxy.wait_until_hidden
        end
      end
    end

    def test_wait_until_hidden__timeout
      proxy = new_proxy

      element_class.expect_initialize
      element_class.any_instance.expects(:visible?).returns(true)

      raised = nil

      with_stubbed_wait_for do
        raised = assert_raise ElementNotHidden do
          proxy.wait_until_hidden
        end
      end

      assert_includes raised.message, element_class.to_s
    end

    def test_wait_until_present
      proxy = new_proxy

      element_class.expect_initialize
      assert_nothing_raised do
        proxy.wait_until_present
      end
    end

    def test_wait_until_present__with_timeout
      proxy = new_proxy

      element_class.expect_initialize
      assert_nothing_raised do
        with_stubbed_wait_for(20) do
          proxy.wait_until_present(20)
        end
      end
    end

    def test_wait_until_present__absent
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)

      raised = nil

      with_stubbed_wait_for do
        raised = assert_raise ElementNotPresent do
          proxy.wait_until_present
        end
      end

      assert_includes raised.message, element_class.to_s
    end

    def test_wait_until_absent
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert_nothing_raised do
        proxy.wait_until_absent
      end
    end

    def test_wait_until_absent__with_timeout
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert_nothing_raised do
        with_stubbed_wait_for(20) do
          proxy.wait_until_absent(20)
        end
      end
    end

    def test_wait_until_absent__present
      proxy = new_proxy

      raised = assert_raise ElementNotAbsent do
        with_stubbed_wait_for do
          element_class.expect_initialize
          proxy.wait_until_absent
        end
      end

      assert_includes raised.message, element_class.to_s
    end

    def test_wait_until_absent__unknown
      proxy = new_proxy

      element_class.expects(:new).raises(Selenium::WebDriver::Error::StaleElementReferenceError)
      capybara_stub.driver.expects(:is_a?).with(Capybara::Selenium::Driver).returns(true)

      raised = assert_raise ElementNotAbsent do
        with_stubbed_wait_for do
          proxy.wait_until_absent
        end
      end

      assert_includes raised.message, element_class.to_s
    end

    def test_class
      proxy = new_proxy

      # Faking an expectation that this method should never be called.
      # Seems it's not possible to use 'expects' on ElementProxy which has
      # removed all (most) methods in implements 'method_missing'
      def proxy.implicit_element(*args)
        address = '0x' + (object_id * 2).to_s(16)
        inspected_object = "#<AePageObjects::ElementProxy:#{address}>"
        message = "unexpected invocation: #{inspected_object}." \
          "implicit_element()\n" \
          "unsatisfied expectations:\n" \
          "- expected never, invoked once: #{inspected_object}." \
          'implicit_element(any_parameters)'

        raise Mocha::ExpectationErrorFactory.build(message, caller)
      end

      assert_equal element_class, proxy.class
    end

    private

    def unstub_wait_for
      waiter_singleton_class.class_eval do
        alias_method :wait_until, :wait_until_whatever
        undef_method :wait_until_whatever
      end
    end

    def waiter_singleton_class
      (class << Waiter; self; end)
    end

    def stub_wait_for(expected_timeout = nil)
      wait_for_mock = mock
      wait_for_mock.expects(:wait_for_called).with(expected_timeout)

      waiter_singleton_class.class_eval do
        alias_method :wait_until_whatever, :wait_until
      end

      waiter_singleton_class.send(:define_method, :wait_until) do |*timeout, &block|
        wait_for_mock.wait_for_called(*timeout)
        block.call
      end
    end

    def with_stubbed_wait_for(expected_timeout = nil)
      stub_wait_for(expected_timeout)
      yield
    ensure
      unstub_wait_for
    end

    def element_class
      @element_class ||= Class.new(Element) do
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
