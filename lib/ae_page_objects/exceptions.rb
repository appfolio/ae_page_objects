module AePageObjects
  class Error < StandardError; end

  class StalePageObject < Error
  end

  class LoadingPageFailed < Error
  end

  class LoadingElementFailed < Error
  end

  class ElementExpectationError < Error
  end

  class ElementNotVisible < ElementExpectationError
  end

  class ElementNotHidden < ElementExpectationError
  end

  class ElementNotPresent < ElementExpectationError
  end

  class ElementNotAbsent < ElementExpectationError
  end

  class PathNotResolvable < Error
  end

  class DocumentLoadError < Error
  end

  class CastError < Error
  end

  class WindowNotFound < Error
  end

  class WaitTimeoutError < Error
  end

  class FrozenInTime < Error
  end
end
