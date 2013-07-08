require 'unit_helper'

module AePageObjects
  class ApplicationTest < Test::Unit::TestCase

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
  end
end