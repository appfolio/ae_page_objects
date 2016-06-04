require 'unit_helper'
require 'unit/multiple_sites_test'

module AePageObjects
  class SiteTest < AePageObjectsTestCase

    def test_from__non_marked_module
      assert_nil Site.from(Object)
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
      assert_nil Site.from(Fa::So::La::Ti::Do)
    end

    module MarkedModule
      include AePageObjects::Universe
    end

    def test_from__marked_module
      site_instance = stub
      MarkedModule.expects(:page_objects_site_class).returns(mock(:instance => site_instance))
      assert_equal site_instance, Site.from(MarkedModule)
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
      site_instance = stub
      Ma.expects(:page_objects_site_class).returns(mock(:instance => site_instance))
      assert_equal site_instance, Site.from(Ma::Rk::Ed::Mod::Ule)
    end

    module PageObjectsWithSite
      class Site < AePageObjects::Site
      end
    end

    module PageObjectsWithSite
      class TestPage < AePageObjects::Document
      end
    end

    def test_site_setup
      assert PageObjectsWithSite < AePageObjects::Universe
      assert_equal PageObjectsWithSite, PageObjectsWithSite::Site.universe
      assert_equal PageObjectsWithSite::Site.instance, PageObjectsWithSite::TestPage.send(:site)
      assert_equal PageObjectsWithSite::Site, PageObjectsWithSite.page_objects_site_class
    end
  end
end
