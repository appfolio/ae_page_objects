require 'unit_helper'

module AePageObjects
  class ApplicationTest < ActiveSupport::TestCase

    def test_from__non_marked_module
      assert_nil Application.from(Object)
    end

    module Fa
      module So
        module La
          module Ti
            module Do
            end
          end
        end
      end
    end

    def test_from__nested_non_marked_module
      assert_nil Application.from(Fa::So::La::Ti::Do)
    end

    module MarkedModule
      include AePageObjects::Universe
    end

    def test_from__marked_module
      application_instance = stub
      MarkedModule.expects(:page_objects_application_class).returns(mock(:instance => application_instance))
      assert_equal application_instance, Application.from(MarkedModule)
    end

    module Ma
      include AePageObjects::Universe

      module Rk
        module Ed
          module Mod
            module Ule
            end
          end
        end
      end
    end

    def test_from__nested_marked_module
      application_instance = stub
      Ma.expects(:page_objects_application_class).returns(mock(:instance => application_instance))
      assert_equal application_instance, Application.from(Ma::Rk::Ed::Mod::Ule)
    end

    module TestPageObjects
      class MyApplication < AePageObjects::Application
        config.paths << "hello"
        config.paths << "kitty"

        module KittyPalace
        end
      end
    end

    def test_resolve_constant
      application = TestPageObjects::MyApplication.instance
      assert_equal [TestPageObjects::MyApplication.called_from, "hello", "kitty"], application.paths

      ConstantResolver.any_instance.expects(:load_constant_from_path).with(TestPageObjects::MyApplication.called_from).returns(nil)
      ConstantResolver.any_instance.expects(:load_constant_from_path).with("hello").returns(nil)
      ConstantResolver.any_instance.expects(:load_constant_from_path).with("kitty").returns("constant")

      assert_equal "constant", application.resolve_constant(TestPageObjects::MyApplication::KittyPalace, :HelloKitty)
    end
  end
end