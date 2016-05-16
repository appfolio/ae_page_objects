module PageObjects
  module Books
    class DummyShowPageWithUnresolvablePath < AePageObjects::Document
      # This page is used to test when the first path is correct, and the second path is incorrect.
      # In the past, the code will blow up with an unreadable error that doesn't indicate that the
      # failure is due to the PathNotResolvable. We now tests that it has a understandable error message.
      path :book
      path :does_not_exist # path that does not actually exist in the app
    end
  end
end
