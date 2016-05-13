require 'test_helpers/element_test_helpers'

module NodeInterfaceTests
  include ElementTestHelpers

  def test_node_method_wraps_not_found
    subject = node_for_node_tests

    AePageObjects::Node::METHODS_TO_DELEGATE_TO_NODE.each do |method|
      error = Capybara::ElementNotFound.new("The message")
      capybara_stub.session.expects(method).with(:args).raises(error)

      raised = assert_raises AePageObjects::LoadingElementFailed do
        subject.send(method, :args)
      end

      assert_equal error.message, raised.message
    end
  end

  def test_element_factory__basic
    subject = node_for_node_tests

    element = subject.element("#blahblah")

    capybara_node = mock
    capybara_stub.session.expects(:find).with("#blahblah").returns(capybara_node)
    verify_element(element, AePageObjects::Element, subject, capybara_node)
  end

  def test_element_factory__locator
    subject = node_for_node_tests

    element = subject.element(:locator => ["#blahblah", {:visible => true}])

    capybara_node = mock
    capybara_stub.session.expects(:find).with("#blahblah", :visible => true).returns(capybara_node)
    verify_element(element, AePageObjects::Element, subject, capybara_node)
  end

  def test_element_factory__element_class
    element_class = Class.new(AePageObjects::Element)

    subject = node_for_node_tests

    element = subject.element(:locator => ["#blahblah", {:visible => true}], :is => element_class)

    capybara_node = mock
    capybara_stub.session.expects(:find).with("#blahblah", :visible => true).returns(capybara_node)
    verify_element(element, element_class, subject, capybara_node)
  end

  private

  def node_for_node_tests
    raise "Must implement!"
  end
end
