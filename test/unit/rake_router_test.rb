require 'unit_helper'

module AePageObjects
  class RakeRouterTest < Test::Unit::TestCase
    
    def test_param
      assert_equal ::AePageObjects::RakeRouter::Param.new(:id, false), ::AePageObjects::RakeRouter::Param.new(:id, false)
      assert_equal ::AePageObjects::RakeRouter::Param.new(:id, false), ::AePageObjects::RakeRouter::Param.new(:id, true)
    end
    
    def test_path__required
      path = ::AePageObjects::RakeRouter::Path.new("/hello/kitty/:id(.:format)")
      assert_equal "/hello/kitty/:id", path
      assert_equal [::AePageObjects::RakeRouter::Param.new(:id, false)], path.params.values
      assert_equal '(?-mix:\\/hello\\/kitty\\/(.+))', path.regex.to_s
      
      assert_raises ArgumentError do
        path.generate({:whatever => 1})
      end
      
      assert_equal '/hello/kitty/EYE', path.generate({:id => 'EYE', :whatever => 1})
    end
    
    def test_path__optional
      path = ::AePageObjects::RakeRouter::Path.new("/hello/kitty(/:id)(.:format)")
      assert_equal "/hello/kitty(/:id)", path
      assert_equal [::AePageObjects::RakeRouter::Param.new(:id, true)], path.params.values
      assert_equal '(?-mix:\\/hello\\/kitty(\\/.+)?)', path.regex.to_s
      
      assert_equal '/hello/kitty', path.generate({:whatever => 1})
      assert_equal '/hello/kitty/EYE', path.generate({:id => 'EYE', :whatever => 1})
    end
    
    def test_path__mixed
      path = ::AePageObjects::RakeRouter::Path.new("/hello(/:homie_id)/kitty/:id(.:format)")
      assert_equal "/hello(/:homie_id)/kitty/:id", path
      assert_sets_equal [::AePageObjects::RakeRouter::Param.new(:id, false), ::AePageObjects::RakeRouter::Param.new(:homie_id, true)], path.params.values
      assert_equal '(?-mix:\\/hello(\\/.+)?\\/kitty\\/(.+))', path.regex.to_s
      
      assert_raises ArgumentError do
        path.generate({:homie_id => 'JK', :whatever => 1})
      end
      
      assert_equal '/hello/JK/kitty/EYE', path.generate({:id => 'EYE', :homie_id => 'JK', :whatever => 1})
      assert_equal '/hello/kitty/EYE', path.generate({:id => 'EYE', :whatever => 1})
    end
    
    def test_parsing
      router = ::AePageObjects::RakeRouter.new(routes)
            
      assert router.path_recognizes_url?(:unhide_property, "/properties/12/unhide")
      assert router.path_recognizes_url?(:past_occupants_property_unit, "/properties/123/units/23/past_occupants")
      assert ! router.path_recognizes_url?(:past_occupants_property_unit, "/properties/12/unhide")
      assert router.path_recognizes_url?(:new_applications_applicants, "/applications/12/applicants/new")
      assert router.path_recognizes_url?(:new_applications_applicants, "/applications/applicants/new")
      
      assert_equal "/properties/123/units/whatever/past_occupants", router.generate_path(:past_occupants_property_unit, :property_id => "123", :id => "whatever")
      assert_equal "/applications/123/applicants/new", router.generate_path(:new_applications_applicants, :web_flow_id => "123")
      assert_equal "/applications/applicants/new", router.generate_path(:new_applications_applicants)

      assert_raises ArgumentError do
        router.generate_path(:past_occupants_property_unit)
      end
      
      assert_equal "/kessler/jon", router.generate_path("/kessler/jon")
    rescue => e
      puts e.backtrace.join("\n")
      raise e
    end
    
    def test_parsing__prefix
      router = ::AePageObjects::RakeRouter.new(routes, "/kessler")

      assert router.path_recognizes_url?(:unhide_property, "/kessler/properties/12/unhide")
      assert router.path_recognizes_url?(:past_occupants_property_unit, "/kessler/properties/123/units/23/past_occupants")
      assert ! router.path_recognizes_url?(:past_occupants_property_unit, "/kessler/properties/12/unhide")
      assert router.path_recognizes_url?(:new_applications_applicants, "/kessler/applications/12/applicants/new")
      assert router.path_recognizes_url?(:new_applications_applicants, "/kessler/applications/applicants/new")
      
      assert_equal "/kessler/properties/123/units/whatever/past_occupants", router.generate_path(:past_occupants_property_unit, :property_id => "123", :id => "whatever")
      assert_equal "/kessler/applications/123/applicants/new", router.generate_path(:new_applications_applicants, :web_flow_id => "123")
      assert_equal "/kessler/applications/applicants/new", router.generate_path(:new_applications_applicants)

      assert_raises ArgumentError do
        router.generate_path(:past_occupants_property_unit)
      end
      
      assert_equal "/kessler/kessler/jon", router.generate_path("/kessler/jon")
    rescue => e
      puts e.backtrace.join("\n")
      raise e
    end
    
    def test_parsing__prefix__root
      router = ::AePageObjects::RakeRouter.new(routes, "/")
      
      assert router.path_recognizes_url?(:unhide_property, "/properties/12/unhide")
      assert router.path_recognizes_url?(:past_occupants_property_unit, "/properties/123/units/23/past_occupants")
      assert ! router.path_recognizes_url?(:past_occupants_property_unit, "/properties/12/unhide")
      assert router.path_recognizes_url?(:new_applications_applicants, "/applications/12/applicants/new")
      assert router.path_recognizes_url?(:new_applications_applicants, "/applications/applicants/new")
      
      assert_equal "/properties/123/units/whatever/past_occupants", router.generate_path(:past_occupants_property_unit, :property_id => "123", :id => "whatever")
      assert_equal "/applications/123/applicants/new", router.generate_path(:new_applications_applicants, :web_flow_id => "123")
      assert_equal "/applications/applicants/new", router.generate_path(:new_applications_applicants)

      assert_raises ArgumentError do
        router.generate_path(:past_occupants_property_unit)
      end
      
      assert_equal "/kessler/jon", router.generate_path("/kessler/jon")
    rescue => e
      puts e.backtrace.join("\n")
      raise e
    end
    
  private
    
    def routes
      <<-ROUTES
                      unhide_property POST   /properties/:id/unhide(.:format)                            {:action=>"unhide", :controller=>"properties"}
            hidden_occupants_property GET    /properties/:id/hidden_occupants(.:format)                  {:action=>"hidden_occupants", :controller=>"properties"}
              list_all_units_property GET    /properties/:id/list_all_units(.:format)                    {:action=>"list_all_units", :controller=>"properties"}
      select_unit_type_property_units POST   /properties/:property_id/units/select_unit_type(.:format)   {:action=>"select_unit_type", :controller=>"units"}
                  list_property_units GET    /properties/:property_id/units/list(.:format)               {:action=>"list", :controller=>"units"}
         past_occupants_property_unit        /properties/:property_id/units/:id/past_occupants(.:format) {:action=>"past_occupants", :method=>:get, :controller=>"units"}
                 unhide_property_unit POST   /properties/:property_id/units/:id/unhide(.:format)         {:action=>"unhide", :controller=>"units"}
                   hide_property_unit POST   /properties/:property_id/units/:id/hide(.:format)           {:action=>"hide", :controller=>"units"}
                                      DELETE /properties/:id(.:format)                                   {:action=>"destroy", :controller=>"properties"}
          new_applications_applicants GET    /applications(/:web_flow_id)/applicants/new(.:format)       {:controller=>"applications/applicants", :action=>"new"}
      ROUTES
    end
  end
end
