module NodeFieldTestHelpers
  
  def assert_nodes_equal(expected, value)
    assert_equal expected.class, value.class
    
    unless expected.respond_to?(:parent) && value.respond_to?(:parent)
      assert_nodes_equal expected.parent, value.parent
    end
    
    assert_equal expected.default_name, value.default_name
    assert_equal expected.__full_name__, value.__full_name__
    assert_equal expected.__name__, value.__name__
  end
  
  def verify_field(parent, field_method, expected_field_type, expected_field_page)
    assert_equal expected_field_type, parent.class.element_attributes[field_method]
  
    parent.send(field_method).tap do |field|
      assert field.is_a?(expected_field_type)
      assert field.is_a?(AePageObjects::ElementProxy)
      assert_equal expected_field_type, field.class
      assert_equal expected_field_page, field.node
      assert_equal parent, field.parent
    end
  end
  
  def verify_field_with_intermediary_class(parent, field_method, expected_field_type, expected_field_page)
    assert_equal expected_field_type, parent.class.element_attributes[field_method].superclass
  
    parent.send(field_method).tap do |field|
      assert field.is_a?(AePageObjects::ElementProxy)
      assert_equal expected_field_type, field.class.superclass
      assert_equal expected_field_page, field.node
      assert_equal parent, field.parent
    end
  end

  def verify_item_field(collection, index, expected_item_type, expected_item_page)
    collection.send(:[], index).tap do |item|
      assert_false item.is_a?(AePageObjects::ElementProxy)
      assert_equal expected_item_type, item.class
      assert_equal collection.item_class, item.class
      assert_equal expected_item_page, item.node
      assert_equal collection, item.parent
    end
  end
  
  def verify_item_field_with_intermediary_class(collection, index, expected_item_type, expected_item_page)
    collection.send(:[], index).tap do |item|
      assert_false item.is_a?(AePageObjects::ElementProxy)
      assert_equal expected_item_type, item.class.superclass
      assert_equal collection.item_class, item.class
      assert_equal expected_item_page, item.node
      assert_equal collection, item.parent
    end
  end
end
