module NodeInterfaceTests
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

private

  def node_for_node_tests
    raise "Must implement!"
  end
end
