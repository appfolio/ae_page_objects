require 'unit_helper'

module AePageObjects
  class VisitableTest < AePageObjectsTestCase
    module PageObjects
      class Site < AePageObjects::Site
      end

      class ShowPage < AePageObjects::Document
        path :show_book
        path :view_book
      end
    end

    def test_visit
      book = stub
      something = stub
      something_else = stub
      full_path = stub
      PageObjects::ShowPage.stubs(:new)
      capybara_stub.session.stubs(:visit).with(full_path).returns(stub)

      PageObjects::Site.any_instance.expects(:generate_path).with(:show_book, book, :format => :json).returns(full_path)
      PageObjects::ShowPage.visit(book, :format => :json)

      PageObjects::Site.any_instance.expects(:generate_path).with(:view_book, book, :format => :json).returns(full_path)
      PageObjects::ShowPage.visit(book, :format => :json, :via => :view_book)

      PageObjects::Site.any_instance.expects(:generate_path).with(:show_book, something, something_else).returns(full_path)
      PageObjects::ShowPage.visit(something, something_else)

      PageObjects::Site.any_instance.expects(:generate_path).with('something', something, something_else, {}).returns(full_path)
      PageObjects::ShowPage.visit(something, something_else, :via => 'something')

      PageObjects::Site.any_instance.expects(:generate_path).with(:show_book, something, something_else, {:param => 'param1'}).returns(full_path)
      PageObjects::ShowPage.visit(something, something_else, :param => 'param1')
    end
  end
end
