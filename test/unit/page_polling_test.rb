require 'unit_helper'
require 'ae_page_objects/util/page_polling'

class PagePollingTest < AePageObjectsTestCase

  class Dummy
    include AePageObjects::PagePolling

    def do_the_poll
      poll_until do
        yield
      end
    end
  end

  def test_poll_until__with_mocks
    AePageObjects.expects(:wait_until).yields
    Capybara.expects(:using_wait_time).with(0).yields

    block = mock
    block.expects(:called).times(1)

    Dummy.new.do_the_poll do
      block.called
    end
  end

  def test_poll_until__without_mocks
    result = Dummy.new.do_the_poll do
      :hello
    end

    assert_equal :hello, result
  end
end
