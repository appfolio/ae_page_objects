module NodeInterfaceTests
  def test_node_method_wraps_not_found
    subject = node_for_node_tests

    AePageObjects::Node::METHODS_TO_DELEGATE_TO_NODE.each do |method|
      capybara_stub.session.expects(method).with(:args).raises(Capybara::ElementNotFound)

      assert_raises AePageObjects::LoadingElementFailed do
        subject.send(method, :args)
      end
    end
  end

private

  def node_for_node_tests
    raise "Must implement!"
  end
end
