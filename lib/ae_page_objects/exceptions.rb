module AePageObjects
  class Error < StandardError; end

  class StalePageObject < Error
  end

  class LoadingPageFailed < Error
  end

  class LoadingElementFailed < Error
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

  class ElementNotVisible < WaitTimeoutError
  end

  class ElementNotHidden < WaitTimeoutError
  end

  class ElementNotPresent < WaitTimeoutError
  end

  class ElementNotAbsent < WaitTimeoutError
  end

  class FrozenInTime < Error
  end
end
