require 'unit_helper'

module AePageObjects
  class ConstantResolverTest < ActiveSupport::TestCase

    module MarkedModule
      include AePageObjects::Universe

      module NestedModule
      end
    end

    def test_load_missing_page_objects_constant__file_does_not_exist
      application_stub = stub(:universe => MarkedModule)
      resolver = ConstantResolver.new(application_stub, MarkedModule::NestedModule, :Whatever)
      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(false)
      assert_nil resolver.load_constant_from_path("root_path")
    end

    def test_load_missing_page_objects_constant__module_loaded
      application_stub = stub(:universe => MarkedModule)
      resolver = ConstantResolver.new(application_stub, MarkedModule::NestedModule, :Whatever)
      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(true)
      ActiveSupport::Dependencies.loaded.expects(:include?).with(includes("root_path/nested_module/whatever.rb")).returns(true)

      assert_nil resolver.load_constant_from_path("root_path")
    end

    def test_load_missing_page_objects_constant__module_does_not_define_const
      application_stub = stub(:universe => MarkedModule)

      resolver = ConstantResolver.new(application_stub, MarkedModule::NestedModule, :Whatever)

      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(true)
      ActiveSupport::Dependencies.loaded.expects(:include?).with(includes("root_path/nested_module/whatever.rb")).returns(false)
      ActiveSupport::Dependencies.expects(:require_or_load).with("root_path/nested_module/whatever.rb")
      ActiveSupport::Dependencies.expects(:local_const_defined?).with(MarkedModule::NestedModule, :Whatever).returns(false)

      assert_raises LoadError do
        resolver.load_constant_from_path("root_path")
      end
    end

    def test_load_missing_page_objects_constant__const_found
      application_stub = stub(:universe => MarkedModule)

      resolver = ConstantResolver.new(application_stub, MarkedModule::NestedModule, :Whatever)

      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(true)
      ActiveSupport::Dependencies.loaded.expects(:include?).with(includes("root_path/nested_module/whatever.rb")).returns(false)
      ActiveSupport::Dependencies.expects(:require_or_load).with("root_path/nested_module/whatever.rb")
      ActiveSupport::Dependencies.expects(:local_const_defined?).with(MarkedModule::NestedModule, :Whatever).returns(true)

      MarkedModule::NestedModule.expects(:const_get).with(:Whatever).returns('yay')

      assert_equal 'yay', resolver.load_constant_from_path("root_path")
    end
  end
end