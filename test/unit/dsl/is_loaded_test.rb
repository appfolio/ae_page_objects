require 'unit_helper'

module AePageObjects
  module Dsl
    class IsLoadedTest < AePageObjectsTestCase
      def test_is_loaded__should_be_class_inheritable_instance_variable
        loaded = []

        document_class = Class.new(AePageObjects::Document)
        animal_class = Class.new(AePageObjects::Element) do
          is_loaded { loaded << 'animal' }
        end
        kitty_class = Class.new(animal_class) do
          is_loaded { loaded << 'kitty' }
        end
        doggy_class = Class.new(animal_class) do
          is_loaded { loaded << 'doggy' }
        end

        capybara_node = stub(:allow_reload!)
        capybara_stub
        capybara_stub.session.stubs(:first).with('#foo').returns(capybara_node)

        loaded.clear
        kitty_class.new(document_class.new, '#foo')
        assert_equal ['animal', 'kitty'], loaded

        loaded.clear
        doggy_class.new(document_class.new, '#foo')
        assert_equal ['animal', 'doggy'], loaded
      end
    end
  end
end
