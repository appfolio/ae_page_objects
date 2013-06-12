require 'unit_helper'

module AePageObjects
  class DependenciesHookTest < ActiveSupport::TestCase

    def test_no_application
      non_marked_module = Object

      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).with(non_marked_module, :Whatever)

      Application.expects(:from).with(non_marked_module).returns(nil)
      mod.load_missing_constant(non_marked_module, :Whatever)
    end
    
    def test_marked_module__constant_found
      marked_module = Module.new

      application_mock = mock()
      application_mock.expects(:resolve_constant).with(marked_module, :Whatever).returns("whatever")
      Application.expects(:from).with(marked_module).returns(application_mock)

      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).never

      assert_equal "whatever", mod.load_missing_constant(marked_module, :Whatever)
    end
    
    def test_marked_module__constant_not_found
      marked_module = Module.new

      application_mock = mock()
      application_mock.expects(:resolve_constant).with(marked_module, :Whatever).returns(nil)
      Application.expects(:from).with(marked_module).returns(application_mock)

      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).with(marked_module, :Whatever).returns("not_found")

      assert_equal "not_found", mod.load_missing_constant(marked_module, :Whatever)
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