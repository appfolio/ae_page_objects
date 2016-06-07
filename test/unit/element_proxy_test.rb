require 'unit_helper'

module AePageObjects
  class ElementProxyTest < AePageObjectsTestCase

    def setup
      super

      # Ensure AePageObjects.wait_until never waits.
      AePageObjects.stubs(:default_max_wait_time).returns(0)
    end

    def test_respond_to_can_find_methods_without_element_not_found
      proxy = new_proxy
      assert proxy.respond_to?(:class)
      assert proxy.respond_to?(:presence)
      assert proxy.respond_to?(:__full_name__)
      refute proxy.respond_to?(:whiz_bang!)
    end

    def test_initialize__no_block
      proxy = new_proxy
      assert_is_proxy proxy

      element_class.expects(:new).returns(:yay)
      assert_equal :yay, proxy.send(:implicit_element)
    end

    def test_methods_forwarded
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:kesslerize_my_love!).returns(:my_deepest_wishes).twice
      assert_equal :my_deepest_wishes, proxy.kesslerize_my_love!
      assert_equal :my_deepest_wishes, proxy.kesslerize_my_love!
    end

    def test_visible
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(true)
      assert proxy.visible?

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(true)
      assert proxy.visible?(wait: 20)

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(false)
      refute proxy.visible?
    end

    def test_visible__element_not_found
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      refute proxy.visible?
    end

    def test_hidden
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(false)
      assert proxy.hidden?

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(false)
      assert proxy.hidden?(wait: 20)

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(true)
      assert ! proxy.hidden?
    end

    def test_hidden__element_not_found
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert proxy.hidden?
    end

    def test_present
      proxy = new_proxy

      element_class.expect_new
      assert proxy.present?

      element_class.expect_new
      assert proxy.present?(wait: 20)
    end

    def test_present__element_not_found
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      refute proxy.present?
    end

    def test_absent
      proxy = new_proxy

      element_class.expect_new
      refute proxy.absent?
    end

    def test_absent__element_not_found
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert proxy.absent?

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert proxy.absent?(wait: 20)
    end

    def test_presence
      proxy = new_proxy

      element_class.expect_new
      assert_is_element proxy.presence
    end

    def test_presence__element_not_found
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)
      assert_nil proxy.presence
    end

    def test_wait_until_visible
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(true)

      proxy.wait_until_visible
    end

    def test_wait_until_visible__timeout
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(false)

      raised = assert_raise ElementNotVisible do
        proxy.wait_until_visible
      end

      assert_include raised.message, element_class.to_s
    end

    def test_wait_until_hidden
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(false)

      proxy.wait_until_hidden
    end

    def test_wait_until_hidden__timeout
      proxy = new_proxy

      element_class.expect_new
      element_class.any_instance.expects(:visible?).returns(true)

      raised = assert_raise ElementNotHidden do
        proxy.wait_until_hidden
      end

      assert_include raised.message, element_class.to_s
    end

    def test_wait_until_present
      proxy = new_proxy

      element_class.expect_new

      proxy.wait_until_present
    end

    def test_wait_until_present__with_timeout
      proxy = new_proxy

      element_class.expect_new

      proxy.wait_until_present(20)
    end

    def test_wait_until_present__absent
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)

      raised = assert_raise ElementNotPresent do
        proxy.wait_until_present
      end

      assert_include raised.message, element_class.to_s
    end

    def test_wait_until_absent
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)

      proxy.wait_until_absent
    end

    def test_wait_until_absent__with_timeout
      proxy = new_proxy

      element_class.expects(:new).raises(AePageObjects::LoadingElementFailed)

      proxy.wait_until_absent(20)
    end

    def test_wait_until_absent__present
      proxy = new_proxy

      element_class.expect_new

      raised = assert_raise ElementNotAbsent do
        proxy.wait_until_absent
      end

      assert_include raised.message, element_class.to_s
    end

    def test_wait_until_absent__unknown
      proxy = new_proxy

      element_class.expects(:new).raises(Selenium::WebDriver::Error::StaleElementReferenceError)
      capybara_stub.driver.expects(:is_a?).with(Capybara::Selenium::Driver).returns(true)

      raised = assert_raise ElementNotAbsent do
        proxy.wait_until_absent
      end

      assert_include raised.message, element_class.to_s
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

    def element_class
      @element_class ||= Class.new(Element) do
        def self.expect_new
          expects(:new).with(1, 2).returns(self.allocate)
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
      refute element.is_a?(ElementProxy)
    end
  end
end
