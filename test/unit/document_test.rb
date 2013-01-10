require 'unit_helper'

module AePageObjects
  class DocumentTest < ActiveSupport::TestCase
  
    def test_page
      kitty_class = ::AePageObjects::Document.new_subclass
      
      document_stub = mock
      Capybara.stubs(:current_session).returns(document_stub)
      
      kitty_page = kitty_class.new
      
      assert_equal document_stub, kitty_page.node
      
      document_stub.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude?as-if=homie", kitty_page.current_url
      
      document_stub.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude", kitty_page.current_url_without_params
    end
    
    def test_find
      kitty_class = ::AePageObjects::Document.new_subclass
        
      document_stub = mock
      Capybara.stubs(:current_session).returns(document_stub)

      kitty_page = kitty_class.new

      document_stub.expects(:find).with(1, 2).returns("result")
      assert_equal "result", kitty_page.find(1, 2)
      
      document_stub.expects(:find).with("hello kids").returns("result")
      kitty_page.find("hello kids")
      
      document_stub.expects(:find).with(:xpath, "yo").returns("result")
      kitty_page.find(:xpath, "yo")
    end
  end
end
