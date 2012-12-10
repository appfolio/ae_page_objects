require 'unit_helper'

module AePageObjects
  class DependenciesHookTest < ActiveSupport::TestCase
    
    def test_non_marked_module
      non_marked_module = Object
      mod = create_test_mod
      mod.expects(:load_missing_constant_sink).with(non_marked_module, :Whatever)
      mod.load_missing_constant(non_marked_module, :Whatever)
    end
    
    def test_marked_module
      marked_module = Module.new do
        include AePageObjects::ConstantResolver
      end
      
      application_module = Module.new do
        def self.all_autoload_paths
          ["here1", "here2", "here3"]
        end
      end
      
      String.any_instance.expects(:constantize).returns(application_module)
      
      mod = create_test_mod

      File.expects(:file?).with("here1/whatever.rb").returns(false)

      File.expects(:file?).with("here2/whatever.rb").returns(true)
      File.expects(:file?).with("here3/whatever.rb").returns(true)

      loaded_mock = mock do |m|
        m.expects(:include?).with do |file|
          file.include?("here2/whatever.rb")
        end.returns(true)
        
        m.expects(:include?).with do |file|
          file.include?("here3/whatever.rb")
        end.returns(false)
      end
      ActiveSupport::Dependencies.stubs(:loaded).returns(loaded_mock)

      ActiveSupport::Dependencies.expects(:require_or_load).with("here3/whatever.rb")

      ActiveSupport::Dependencies.expects(:local_const_defined?).with do |mod, const_name|
        (marked_module == mod && :Whatever == const_name).tap do |result|
          marked_module.const_set(:Whatever, "yaya!") if result
        end
      end.returns(true)
      
      mod.expects(:load_missing_constant_sink).never

      assert_equal "yaya!", mod.load_missing_constant(marked_module, :Whatever)    
    end
    
    protected
    
    def create_test_mod
      tracer = Module.new do
        def load_missing_constant(from_mod, const_name)
          load_missing_constant_sink(from_mod, const_name)
        end
      end

      Module.new.tap do |mod|
        mod.extend mod
        
        mod.extend tracer
        mod.extend AePageObjects::DependenciesHook
      end
    end
  end
end