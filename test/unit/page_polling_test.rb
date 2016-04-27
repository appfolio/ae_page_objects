require 'unit_helper'
require 'ae_page_objects/util/page_polling'

class PagePollingTest < AePageObjectsTestCase

  class Dummy
    extend AePageObjects::PagePolling
  end

  def test_poll_until__with_mocks
    AePageObjects.expects(:wait_until).yields
    Capybara.expects(:using_wait_time).with(0).yields

    block = mock
    block.expects(:called).times(1)

    Dummy.poll_until do
      block.called
    end
  end

  def test_poll_until__without_mocks
    result = Dummy.poll_until do
      :hello
    end

    assert_equal :hello, result
  end
end
