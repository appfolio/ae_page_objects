require 'unit_helper'

class AePageObjectsTest < AePageObjectsTestCase

  def test_browser__selenium
    Capybara.expects(:current_session).returns(mock(:driver => Capybara::Selenium::Driver.new(mock)))
    assert_equal AePageObjects::MultipleWindows::Browser, AePageObjects.browser.class
  end

  def test_browser__other
    Capybara.expects(:current_session).returns(mock(:driver => Object.new))
    assert_equal AePageObjects::SingleWindow::Browser, AePageObjects.browser.class
  end
end

