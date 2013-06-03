require 'unit_helper'

module AePageObjects
  class ConstantResolverTest < ActiveSupport::TestCase

    module ApplicationModule
      def self.root_path
        ["root_path"]
      end

      def self.instance
        self
      end
    end

    module MarkedModule
      include AePageObjects::ConstantResolver
      self.page_objects_application = ApplicationModule

      module NestedModule
      end
    end

    def test_load_missing_page_objects_constant__file_does_not_exist
      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(false)
      assert_nil MarkedModule.load_missing_page_objects_constant(MarkedModule::NestedModule, :Whatever)
    end

    def test_load_missing_page_objects_constant__module_loaded
      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(true)
      ActiveSupport::Dependencies.loaded.expects(:include?).with(includes("root_path/nested_module/whatever.rb")).returns(true)
      
      assert_nil MarkedModule.load_missing_page_objects_constant(MarkedModule::NestedModule, :Whatever)
    end

    def test_load_missing_page_objects_constant__module_does_not_define_const
      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(true)
      ActiveSupport::Dependencies.loaded.expects(:include?).with(includes("root_path/nested_module/whatever.rb")).returns(false)
      ActiveSupport::Dependencies.expects(:require_or_load).with("root_path/nested_module/whatever.rb")
      ActiveSupport::Dependencies.expects(:local_const_defined?).with(MarkedModule::NestedModule, :Whatever).returns(false)

      assert_raises LoadError do
        MarkedModule.load_missing_page_objects_constant(MarkedModule::NestedModule, :Whatever)
      end
    end

    def test_load_missing_page_objects_constant__const_found
      File.expects(:file?).with("root_path/nested_module/whatever.rb").returns(true)
      ActiveSupport::Dependencies.loaded.expects(:include?).with(includes("root_path/nested_module/whatever.rb")).returns(false)
      ActiveSupport::Dependencies.expects(:require_or_load).with("root_path/nested_module/whatever.rb")
      ActiveSupport::Dependencies.expects(:local_const_defined?).with(MarkedModule::NestedModule, :Whatever).returns(true)

      MarkedModule::NestedModule.expects(:const_get).with(:Whatever).returns('yay')

      assert_equal 'yay', MarkedModule.load_missing_page_objects_constant(MarkedModule::NestedModule, :Whatever)
    end
  end
end