require 'unit_helper'

module AePageObjects
  class DependenciesHookTest < ActiveSupport::TestCase

    def test_non_marked_module
      non_marked_module = Object
      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).with(non_marked_module, :Whatever)
      mod.load_missing_constant(non_marked_module, :Whatever)
    end
    
    def test_marked_module__constant_found
      marked_module = Module.new do
        include AePageObjects::ConstantResolver
      end

      marked_module.expects(:load_missing_page_objects_constant).with(marked_module, :Whatever).returns(true)

      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).never

      mod.load_missing_constant(marked_module, :Whatever)
    end
    
    def test_marked_module__constant_not_found
      marked_module = Module.new do
        include AePageObjects::ConstantResolver
      end

      marked_module.expects(:load_missing_page_objects_constant).with(marked_module, :Whatever).returns(false)

      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).with(marked_module, :Whatever)

      mod.load_missing_constant(marked_module, :Whatever)
    end

  protected
    
    def create_test_mod
      tracer = Module.new do
        def load_missing_constant(from_mod, const_name)
          load_missing_constant_sink(from_mod, const_name)
        end
      end

      Module.new.tap do |mod|
        mod.extend tracer
        mod.extend AePageObjects::DependenciesHook
      end
    end
  end
end