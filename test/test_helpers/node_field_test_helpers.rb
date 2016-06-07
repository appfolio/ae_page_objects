module NodeFieldTestHelpers

  def assert_nodes_equal(expected, value)
    assert_equal expected.class, value.class

    unless expected.respond_to?(:parent) && value.respond_to?(:parent)
      assert_nodes_equal expected.parent, value.parent
    end

    assert_equal expected.__full_name__, value.__full_name__
    assert_equal expected.__name__, value.__name__
  end

  def verify_element(element, expected_element_type, expected_parent, expected_capybara_node)
    assert element.is_a?(expected_element_type)
    assert element.is_a?(AePageObjects::ElementProxy)
    assert_equal expected_element_type, element.class
    assert_equal expected_capybara_node, element.node
    assert_equal expected_parent, element.parent
  end

  def verify_element_on_parent(parent, field_method, expected_field_type, expected_field_page)
    assert_equal expected_field_type, parent.class.element_attributes[field_method]

    parent.send(field_method).tap do |field|
      verify_element(field, expected_field_type, parent, expected_field_page)
    end
  end

  def verify_element_on_parent_with_intermediary_class(parent, field_method, expected_field_type, expected_field_page)
    assert_equal expected_field_type, parent.class.element_attributes[field_method].superclass

    parent.send(field_method).tap do |field|
      assert field.is_a?(AePageObjects::ElementProxy)
      assert_equal expected_field_type, field.class.superclass
      assert_equal expected_field_page, field.node
      assert_equal parent, field.parent
    end
  end
end
